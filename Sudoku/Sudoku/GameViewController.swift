//
//  GameViewController.swift
//  Sudoku
//
//  Created by 박재우 on 11/20/23.
//

import UIKit

class GameViewController: UIViewController {
    private lazy var backBarButtonItem = UIBarButtonItem.back(self, selector: #selector(tappedBackBarButton))
    private lazy var pauseBarButtonItem = UIBarButtonItem.pause(self, selector: #selector(tappedPauseBarButton))

    private let informationStackView = InformationStackView()
    private let boardView = BoardView()
    private let abilityStackView = AbilityStackView()
    private let numberStackView = NumberStackView()

    var cursor: IndexPath?
    var timer: Timer?
    var sudoku: Sudoku!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        LoadingIndicator.showLoading()

        if let sudoku {
            configure(of: sudoku)
            LoadingIndicator.hideLoading()
        } else {
            requestSudoku()
        }

        setUI()
        setLayout()

        boardView.sections.forEach { sectionView in
            sectionView.delegate = self
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
            numberStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    @objc private func tappedBackBarButton(_ sender: UIBarButtonItem) {
        sudoku.isOnMemo = false
        if let encoded = try? JSONEncoder().encode(sudoku) {
            UserDefaults.standard.setValue(encoded, forKey: "Sudoku")
        }
        self.navigationController?.popViewController(animated: true)
    }

    @objc private func tappedPauseBarButton(_ sender: UIBarButtonItem) {
        if let timer, !timer.isValid {
            pauseBarButtonItem.image = UIImage(systemName: "pause.circle")
            self.timer = Timer.startRepeating(self, selector: #selector(runTime))
        } else {
            pauseBarButtonItem.image = UIImage(systemName: "play.circle")
            timer?.invalidate()
        }
    }

    @objc private func runTime() {
        sudoku.time += 1
        informationStackView.configure(.timer(content: sudoku.time))
    }

    @objc private func tappedNumberButton(_ sender: NumberButton) {
        guard let cursor else {
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

    private func requestSudoku() {
        Networking().loadData { result in
            switch result {
            case .success(let sudokuData):
                let sudoku = Sudoku(data: sudokuData)

                DispatchQueue.main.async {
                    self.sudoku = sudoku
                    self.configure(of: sudoku)
                }
            case .failure(let failure):
                print(failure)
            }

            LoadingIndicator.hideLoading()
        }
    }

    private func configure(of sudoku: Sudoku) {
        boardView.updateAll(sudoku.board) { indexPath in
            paintText(associated: indexPath)
        }
        informationStackView.configure(.mistake(content: sudoku.mistake))
        informationStackView.configure(.timer(content: sudoku.time))
        informationStackView.configure(.difficulty(content: sudoku.data.difficulty.discription))
        timer = Timer.startRepeating(self, selector: #selector(runTime))
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
}

extension GameViewController: SectionViewDelegate {
    func cellButtonTapped(_ button: CellButton) {
        cursor = button.indexPath

        paint(associated: button.indexPath)
    }
}
