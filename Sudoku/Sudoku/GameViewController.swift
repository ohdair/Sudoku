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

    private var cursor: IndexPath?
    private var informationViewModel: InformationViewModel!
    private var alertViewModelInput: AlertViewModel.Input!
    private var alertViewController: AlertViewController!

    var sudoku: Sudoku!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setUI()
        setLayout()
        configureSudoku()

        setViewModel()

        bindAlertViewModel()
        bindAlertButtons()
        bindInformationViewModel()
    }

    func setViewModel() {
        informationViewModel = InformationViewModel(
            difficulty: sudoku.data.difficulty,
            mistake: sudoku.mistake,
            time: Int(sudoku.time)
        )
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
            mistakeTrigger: PublishSubject<Void>().asDriver(onErrorJustReturn: ()),
            errorTrigger: PublishSubject<Void>().asDriver(onErrorJustReturn: ())
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
                // 새로운 Sudoku Fetch
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
                // 기본적인 Sudoku 문제를 제외한 데이터 삭제
            }
            .disposed(by: disposeBag)
    }

    func bindInformationViewModel() {
        let toggleTimerDriver = Driver.merge(
            pauseBarButtonItem.rx.tap.asDriver(),
            backBarButtonItem.rx.tap.asDriver(),
            alertViewController.alertButton(of: .continue).rx.tap.asDriver()
        )

        let input = InformationViewModel.Input(
            toggleTimer: toggleTimerDriver,
            mistakeTrigger: PublishSubject<Void>().asDriver(onErrorJustReturn: ())
        )

        let output = informationViewModel.transform(input: input)

        output.difficulty
            .drive(self.informationStackView.label(of: .difficulty).rx.text)
            .disposed(by: disposeBag)

        output.mistake
            .map { "\($0) / 3"}
            .drive(self.informationStackView.label(of: .mistake).rx.text)
            .disposed(by: disposeBag)

        output.time
            .map { self.formatSeconds($0) }
            .drive(self.informationStackView.label(of: .timer).rx.text)
            .disposed(by: disposeBag)

        output.isOnTimer
            .drive { isOn in
                self.setPauseBarButtonImage(through: isOn)
            }
            .disposed(by: disposeBag)
    }

    private func setPauseBarButtonImage(through isOn: Bool) {
        if isOn {
            self.pauseBarButtonItem.image = UIImage(systemName: "pause.circle")
        } else {
            self.pauseBarButtonItem.image = UIImage(systemName: "play.circle")
        }
    }

    private func configureSudoku() {
        if let sudoku {
            configure(of: sudoku)
        } else {
            requestSudoku()
        }
    }

    private func setUI() {
        self.title = "Sudoku"
        let navigationBar = self.navigationController?.navigationBar
        navigationBar?.titleTextAttributes = [.font: UIFont.systemFont(ofSize: 22, weight: .bold),
                                              .foregroundColor: UIColor.darkMainColor2]
        self.navigationItem.leftBarButtonItem = backBarButtonItem
        self.navigationItem.rightBarButtonItem = pauseBarButtonItem

        numberStackView.addTargetNumberButtons(self, selector: #selector(tappedNumberButton))
        abilityStackView.addTarget(self, selector: #selector(tappedMemoButton), ability: .memo)
        abilityStackView.addTarget(self, selector: #selector(tappedUndoButton), ability: .undo)
        abilityStackView.addTarget(self, selector: #selector(tappedEraseButton), ability: .erase)
        boardView.sections.forEach { sectionView in
            sectionView.delegate = self
        }
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

    @objc private func tappedNumberButton(_ sender: NumberButton) {
        guard let cursor,
              !sudoku.isProblem(indexPath: cursor) else {
            return
        }

        sudoku.update(number: sender.number, indexPath: cursor)
        sudoku.history.append(sudoku.board)
        let sudokuItem = sudoku.item(of: cursor)
        let cellButton = boardView.cellButton(of: cursor)
        cellButton.update(to: sudokuItem)

        if !sudoku.isOnMemo {
            paint(associated: cursor)
        }

        if sudoku.isMistake(indexPath: cursor) {
            increaseMistake()
        }
    }

    @objc private func tappedUndoButton(_ sender: AbilityButton) {
        guard sudoku.history.count > 1,
              let currentBoard = sudoku.history.popLast(),
              let previousBoard = sudoku.history.last
        else { return }

        zip(currentBoard, previousBoard)
            .compactMapMatrix { currentItem, previousItem in
                currentItem == previousItem ? nil : previousItem
            }
            .forEachMatrix { row, column, sudokuItem in
                if let sudokuItem {
                    let indexPath = sudoku.indexPath(row: row, column: column)
                    let cellButton = boardView.cellButton(of: indexPath)
                    sudoku.update(item: sudokuItem, indexPath: indexPath)
                    DispatchQueue.main.async {
                        cellButton.update(to: sudokuItem)
                        self.paint(associated: indexPath)
                    }
                }
            }

    }

    @objc private func tappedEraseButton(_ sender: AbilityButton) {
        guard let cursor else { return }
        sudoku.erase(indexPath: cursor)
        sudoku.history.append(sudoku.board)

        let sudokuItem = sudoku.item(of: cursor)
        let cellButton = boardView.cellButton(of: cursor)
        cellButton.update(to: sudokuItem)
        paint(associated: cursor)
    }

    @objc private func tappedMemoButton(_ sender: AbilityButton) {
        sender.toggleMemo()
        sudoku.isOnMemo = sender.isOnMemo
    }

    @objc private func requestSudoku() {
        LoadingIndicator.showLoading()

        Networking.request()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { sudokuData in
                let sudoku = Sudoku(data: sudokuData)
                self.sudoku = sudoku
                self.configure(of: sudoku)
            }, onError: { error in
                print(error)
                LoadingIndicator.hideLoading()
//                self.alert(type: .error)
            })
            .disposed(by: disposeBag)
    }

    @objc private func reConfigure() {
        let sudoku = Sudoku(data: sudoku.data)

        self.sudoku = sudoku
        configure(of: sudoku)
        boardView.paintedReset()
    }

    private func configure(of sudoku: Sudoku) {
        LoadingIndicator.showLoading()
        boardView.updateAll(sudoku.board) { indexPath in
            paintText(associated: indexPath)
        }
        boardView.paintedReset()
        pauseBarButtonItem.image = UIImage(systemName: "pause.circle")
        LoadingIndicator.hideLoading()

        // MARK: - RxSwift Test
        informationViewModel = InformationViewModel(
            difficulty: sudoku.data.difficulty,
            mistake: sudoku.mistake,
            time: Int(sudoku.time)
        )
    }

    private func paint(associated indexPath: IndexPath) {
        let associatedIndexPaths = sudoku.associatedIndexPaths(indexPath: indexPath)
        let associatedNumbers = sudoku.associatedNumbers(indexPath: indexPath)
        boardView.paintedReset()
        boardView.paint(to: associatedIndexPaths, into: .associatedCursor)
        boardView.paint(to: indexPath, into: .selected)
        boardView.paint(to: associatedNumbers, into: .associatedNumber)

        if sudoku.isMistake(indexPath: indexPath) {
            let associatedMistake = sudoku.mistake(indexPath: indexPath)
            boardView.paint(to: associatedMistake, into: .mistake)
        }

        paintText(associated: indexPath)
    }

    private func paintText(associated indexPath: IndexPath) {
        guard !sudoku.isProblem(indexPath: indexPath) else {
            boardView.paintText(to: indexPath, into: .problem)
            return
        }

        if sudoku.isMistake(indexPath: indexPath) {
            boardView.paintText(to: indexPath, into: .mistake)
        } else {
            boardView.paintText(to: indexPath, into: .selected)
        }
    }

    private func increaseMistake() {
        sudoku.increaseMistake()

        if sudoku.isOverMistake {
//            alert(type: .overMistake)
        }
    }

}

extension GameViewController: SectionViewDelegate {
    func cellButtonTapped(_ button: CellButton) {
        cursor = button.indexPath

        paint(associated: button.indexPath)
    }

    func formatSeconds(_ second: Int) -> String {
        String(format: "%d:%02d", Int(second/60), Int(second % 60))
    }
}
