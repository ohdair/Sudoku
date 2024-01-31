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

    // MARK: - NavigationBarButton
    private let backBarButtonItem = UIBarButtonItem.back()
    private let pauseBarButtonItem = UIBarButtonItem.pause()

    // MARK: - UI
    private let informationStackView = InformationStackView()
    private let boardView = BoardView()
    private let abilityStackView = AbilityStackView()
    private let numberStackView = NumberStackView()
    private let sphereEmitterView = SphereEmitterView()
    private var alertViewController: AlertViewController!

    // MARK: - ViewModel
    private var gameViewModel: GameViewModel!

    private let alertTrigger = PublishRelay<AlertView.Alert>()
    private let viewWillDisappear = PublishRelay<Void>()
    private let disposeBag = DisposeBag()

    convenience init(viewModel: GameViewModel) {
        self.init()
        self.gameViewModel = viewModel
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if gameViewModel == nil {
            gameViewModel = GameViewModel()
        }

        setUI()
        setLayout()

        bindAlertViewModel()
        bindButtons()
        bindGameViewModel()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        viewWillDisappear.accept(())
    }

    func bindGameViewModel() {
        let viewDidLoad = PublishSubject<Void>()
        let timerTrigger = Driver.merge(
            alertTrigger.map { _ in () }.asDriver(onErrorJustReturn: ()),
            alertViewController.alertButton(of: .continue).rx.tap.asDriver()
        )

        let newGameTapped = alertViewController.alertButton(of: .new).rx.tap.asDriver()
        let reGameTapped = alertViewController.alertButton(of: .restart).rx.tap.asDriver()

        let input = GameViewModel.Input(
            viewDidLoad: viewDidLoad.asObservable(),
            timerTrigger: timerTrigger,
            newGameTapped: newGameTapped,
            reGameTapped: reGameTapped,
            cellButtonTapped: cellButtonTapped(),
            abilityButtonTapped: abilityButtonTapped(),
            numberButtonTapped: numberButtonTapped(),
            saveGameTrigger: viewWillDisappear.asObservable()
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
            .filter { $0 == 3 }
            .drive { _ in
                self.alertTrigger.accept(.overMistake)
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
            .asObservable()
            .do { _ in self.sphereEmitterView.emit() }
            .flatMap { _ in self.mergedObservablesForEndgame() }
            .first()
            .subscribe { _ in
                self.sphereEmitterView.remove()
                self.alertTrigger.accept(.success)
            }
            .disposed(by: disposeBag)

        output.sudoku
            .observe(on: MainScheduler.instance)
            .subscribe(onCompleted: {
                self.alertTrigger.accept(.error)
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

    private func mergedObservablesForEndgame() -> Observable<Void> {
        let tapObservable = sphereEmitterView.observeTap()

        let delayedObservable = Observable<Void>.just(())
            .delay(.seconds(5), scheduler: MainScheduler.instance)

        return Observable.merge(tapObservable, delayedObservable)
    }

    private func bindAlertViewModel() {
        alertTrigger
            .subscribe { _ in
                self.present(self.alertViewController, animated: true)
            }
            .disposed(by: disposeBag)

        let input = AlertViewModel.Input(alertTrigger: alertTrigger.asObservable())

        alertViewController = AlertViewController(input: input)
        alertViewController.modalPresentationStyle = .overFullScreen
    }

    private func bindButtons() {
        // MARK: - NavigationBarItem
        backBarButtonItem.rx.tap
            .subscribe { _ in
                self.alertTrigger.accept(.back)
            }
            .disposed(by: disposeBag)

        pauseBarButtonItem.rx.tap
            .subscribe { _ in
                self.alertTrigger.accept(.pause)
            }
            .disposed(by: disposeBag)

        // MARK: - AlertButtons of AlertViewController
        Driver
            .merge(
                alertViewController.alertButton(of: .new).rx.tap.asDriver(),
                alertViewController.alertButton(of: .continue).rx.tap.asDriver(),
                alertViewController.alertButton(of: .restart).rx.tap.asDriver()
            )
            .drive { _ in
                self.dismiss(animated: true)
            }
            .disposed(by: disposeBag)

        alertViewController.alertButton(of: .quit).rx.tap
            .asDriver()
            .drive { _ in
                self.dismiss(animated: false)
                self.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
    }

    private func setUI() {
        view.backgroundColor = .systemBackground
        title = "Sudoku"
        let navigationBar = self.navigationController?.navigationBar
        navigationBar?.titleTextAttributes = [.font: UIFont.systemFont(ofSize: 22, weight: .bold),
                                              .foregroundColor: UIColor.darkMainColor2]
        navigationItem.leftBarButtonItem = backBarButtonItem
        navigationItem.rightBarButtonItem = pauseBarButtonItem
    }

    private func setLayout() {
        view.addSubview(informationStackView)
        view.addSubview(boardView)
        view.addSubview(abilityStackView)
        view.addSubview(numberStackView)
        view.addSubview(sphereEmitterView)

        informationStackView.translatesAutoresizingMaskIntoConstraints = false
        boardView.translatesAutoresizingMaskIntoConstraints = false
        abilityStackView.translatesAutoresizingMaskIntoConstraints = false
        numberStackView.translatesAutoresizingMaskIntoConstraints = false
        sphereEmitterView.translatesAutoresizingMaskIntoConstraints = false

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

            sphereEmitterView.topAnchor.constraint(equalTo: view.topAnchor),
            sphereEmitterView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sphereEmitterView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sphereEmitterView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

}
