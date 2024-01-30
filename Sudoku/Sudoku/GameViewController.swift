//
//  GameViewController.swift
//  Sudoku
//
//  Created by 박재우 on 11/20/23.
//

import UIKit
import RxSwift
import RxCocoa

class GameViewController: UIViewController {

    private let backBarButtonItem = UIBarButtonItem.back()
    private let pauseBarButtonItem = UIBarButtonItem.pause()

    private let informationStackView = InformationStackView()
    private let boardView = BoardView()
    private let abilityStackView = AbilityStackView()
    private let numberStackView = NumberStackView()
    private let disposeBag = DisposeBag()

    private var informationViewModel: InformationViewModel!
    private var alertViewModelInput: AlertViewModel.Input!
    private var alertViewController: AlertViewController!

    private var gameViewModel: GameViewModel!

    private let errorTrigger = PublishRelay<Void>()
    private let overMistakeTrigger = PublishRelay<Void>()

    var sudoku: Sudoku!

    convenience init(viewModel: GameViewModel) {
        self.init()
        self.gameViewModel = viewModel
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        if gameViewModel == nil {
            gameViewModel = GameViewModel()
        }

        setUI()
        setLayout()
//        configureSudoku()

        
        // sudoku fetch 하는 동안
        // viewmodel 설정을 기다리도록

        bindAlertViewModel()
        bindAlertButtons()
        bindGameViewModel()
    }

    func bindGameViewModel() {
        let viewDidLoad = PublishSubject<Void>()
        let timerTrigger = Driver.merge(
            pauseBarButtonItem.rx.tap.asDriver(),
            backBarButtonItem.rx.tap.asDriver(),
            alertViewController.alertButton(of: .continue).rx.tap.asDriver()
        )

        let newGameTapped = alertViewController.alertButton(of: .new).rx.tap.asDriver()
        let reGmaeTapped = alertViewController.alertButton(of: .restart).rx.tap.asDriver()

        let input = GameViewModel.Input(
            viewDidLoad: viewDidLoad.asObservable(),
            timerTrigger: timerTrigger,
            newGameTapped: newGameTapped,
            reGameTapped: reGmaeTapped,
            cellButtonTapped: cellButtonTapped(),
            abilityButtonTapped: abilityButtonTapped(),
            numberButtonTapped: numberButtonTapped()
        )

        let output = gameViewModel.transform(input: input)

        output.board
            .drive { board in
                board.forEachMatrix { row, column, sudokuItem in
                    let indexPath = IndexPath(row: row, column: column)
                    let button = self.boardView.cellButton(of: indexPath)
                    button.update(to: sudokuItem)
                }
            }
            .disposed(by: disposeBag)

        output.loading
            .drive { isLoading in
                isLoading ? LoadingIndicator.showLoading() : LoadingIndicator.hideLoading()
            }
            .disposed(by: disposeBag)

        output.isOnMemo
            .drive(self.abilityStackView.button(of: .memo).rx.isOnMemo)
            .disposed(by: disposeBag)

        // MARK: - InformationView
        output.informationOutput.difficulty
            .drive(self.informationStackView.label(of: .difficulty).rx.text)
            .disposed(by: disposeBag)

        output.informationOutput.mistake
            .map { "\($0) / 3"}
            .drive(self.informationStackView.label(of: .mistake).rx.text)
            .disposed(by: disposeBag)

        output.informationOutput.mistake
            .map { $0 == 3 }
            .filter { $0 }
            .map { _ in }
            .drive { _ in
                self.overMistakeTrigger.accept(())
                self.present(self.alertViewController, animated: true)
            }
            .disposed(by: disposeBag)

        output.informationOutput.time
            .map { $0.time }
            .drive(self.informationStackView.label(of: .timer).rx.text)
            .disposed(by: disposeBag)

        // MARK: - BoardView
        output.boardOutput.cursor
            .drive { cursor in
                self.boardView.paintedReset()
                self.boardView.paint(to: cursor, into: .selected)
            }
            .disposed(by: disposeBag)

        output.boardOutput.associatedIndexPaths
            .drive { indexPaths in
                self.boardView.paint(to: indexPaths, into: .associatedCursor)
            }
            .disposed(by: disposeBag)

        output.boardOutput.associatedNumbers
            .drive { indexPaths in
                self.boardView.paint(to: indexPaths, into: .associatedNumber)
            }
            .disposed(by: disposeBag)

        output.boardOutput.cursorState
            .withLatestFrom(output.boardOutput.cursor) { state, cursor in
                return (cursor, state)
            }
            .drive { cursor, state in
                self.boardView.paintText(to: cursor, into: state)
            }
            .disposed(by: disposeBag)

        output.boardOutput.associatedMistake
            .drive { indexPaths in
                self.boardView.paint(to: indexPaths, into: .mistake)
            }
            .disposed(by: disposeBag)

        output.boardOutput.endGameTrigger
            .drive { _ in
                // MARK: - 종료에 관한 이벤트 추가
            }
            .disposed(by: disposeBag)

        output.sudoku
            .observe(on: MainScheduler.instance)
            .subscribe(onCompleted: {
                self.errorTrigger.accept(())
                self.present(self.alertViewController, animated: true)
            })
            .disposed(by: disposeBag)

        viewDidLoad.onNext(())
    }

    private func cellButtonTapped() -> Driver<IndexPath> {
        let cellButtonDrivers = boardView.sections.flatMap { sectionView in
            sectionView.buttons.map { button in
                let tapEvent = button.rx.tap
                let driver = tapEvent
                    .map { button.indexPath }
                    .asDriver(onErrorJustReturn: IndexPath())
                return driver
            }
        }

        return Driver.merge(cellButtonDrivers)
    }

    private func abilityButtonTapped() -> Driver<AbilityButton.Ability> {
        let abilityButtonDrivers = abilityStackView.subviews.map { subview in
            let abilityButton = subview as! AbilityButton
            let tapEvent = abilityButton.rx.tap
            let driver = tapEvent
                .map { abilityButton.type }
                .asDriver(onErrorJustReturn: .erase)
            return driver
        }

        return Driver.merge(abilityButtonDrivers)
    }

    private func numberButtonTapped() -> Driver<Int> {
        let numberButtonDrivers = numberStackView.numberButtons.map { button in
            let tapEvent = button.rx.tap
            let driver = tapEvent
                .map { button.number }
                .asDriver(onErrorJustReturn: 0)
            return driver
        }

        return Driver.merge(numberButtonDrivers)
    }

    func bindAlertViewModel() {
        let pauseButtonTapped = pauseBarButtonItem.rx.tap.asDriver()
        let backButtonTapped = backBarButtonItem.rx.tap.asDriver()

        Driver.merge(pauseButtonTapped, backButtonTapped)
            .drive { _ in
                self.present(self.alertViewController, animated: true)
            }
            .disposed(by: disposeBag)

        alertViewModelInput = AlertViewModel.Input(
            backButtonTapped: backButtonTapped,
            pauseButtonTapped: pauseButtonTapped,
            mistakeTrigger: overMistakeTrigger.asDriver(onErrorJustReturn: ()),
            errorTrigger: errorTrigger.asDriver(onErrorJustReturn: ())
        )

        alertViewController = AlertViewController(input: alertViewModelInput)
        alertViewController.modalPresentationStyle = .overFullScreen
    }

    func bindAlertButtons() {
        alertViewController.alertButton(of: .continue).rx.tap
            .asDriver()
            .drive { _ in
                self.dismiss(animated: true)
            }
            .disposed(by: disposeBag)

        alertViewController.alertButton(of: .new).rx.tap
            .asDriver()
            .drive { _ in
                self.dismiss(animated: true)
            }
            .disposed(by: disposeBag)

        alertViewController.alertButton(of: .quit).rx.tap
            .asDriver()
            .drive { _ in
                if let sudoku = self.sudoku,
                   let encoded = try? JSONEncoder().encode(sudoku) {
                    UserDefaults.standard.setValue(encoded, forKey: "Sudoku")
                }
                self.dismiss(animated: false)
                self.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)

        alertViewController.alertButton(of: .restart).rx.tap
            .asDriver()
            .drive { _ in
                self.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
    }

    private func setUI() {
        self.title = "Sudoku"
        let navigationBar = self.navigationController?.navigationBar
        navigationBar?.titleTextAttributes = [.font: UIFont.systemFont(ofSize: 22, weight: .bold),
                                              .foregroundColor: UIColor.darkMainColor2]
        self.navigationItem.leftBarButtonItem = backBarButtonItem
        self.navigationItem.rightBarButtonItem = pauseBarButtonItem
    }

    private func setLayout() {
        view.addSubview(informationStackView)
        view.addSubview(boardView)
        view.addSubview(abilityStackView)
        view.addSubview(numberStackView)
        

        informationStackView.translatesAutoresizingMaskIntoConstraints = false
        boardView.translatesAutoresizingMaskIntoConstraints = false
        abilityStackView.translatesAutoresizingMaskIntoConstraints = false
        numberStackView.translatesAutoresizingMaskIntoConstraints = false
        

        NSLayoutConstraint.activate([
            informationStackView.widthAnchor.constraint(equalTo: view.widthAnchor),
            informationStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            informationStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            boardView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -10),
            boardView.heightAnchor.constraint(equalTo: boardView.widthAnchor),
            boardView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            boardView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),

            abilityStackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            abilityStackView.topAnchor.constraint(equalTo: boardView.bottomAnchor, constant: 30),
            abilityStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            numberStackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            numberStackView.topAnchor.constraint(equalTo: abilityStackView.bottomAnchor, constant: 30),
            numberStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }

}
