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

    private let informationStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillEqually
        return stackView
    }()

    private let boardView = BoardView()

    private let abilityStackView = {
        let stackView = UIStackView()
        stackView.distribution = .equalCentering
        return stackView
    }()

    private let numberStackView = {
        let stackView = UIStackView()
        stackView.distribution = .equalCentering
        return stackView
    }()

    private let difficultyView = InformationView()
    private let mistakeView = InformationView()
    private let timerView = InformationView()

    var cursor: IndexPath?
    var timer: Timer?
    var time = 0
    var sudoku: Sudoku?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        if let sudoku {
            boardView.updateAll(sudoku.data.problem)
            difficultyView.updateContent(by: .difficulty(content: sudoku.data.difficulty.discription))
        } else {
            requestSudoku()
        }

        timer = Timer.startRepeating(self, selector: #selector(runTime))
        timer?.tolerance = 0.1

        setUI()
        setLayout()

        difficultyView.updateContent(by: .difficulty(content: "쉬움"))
        mistakeView.updateContent(by: .mistake(content: 0))
        timerView.updateContent(by: .timer(content: time))

        informationStackView.addArrangedSubview(difficultyView)
        informationStackView.addArrangedSubview(mistakeView)
        informationStackView.addArrangedSubview(timerView)

        // MARK: - Board Test
        boardView.sections.forEach { sectionView in
            sectionView.delegate = self
        }

        AbilityButton.Ability.allCases.forEach { ability in
            let abilityButton = AbilityButton(of: ability)
            abilityStackView.addArrangedSubview(abilityButton)

            if ability == .memo {
                abilityButton.addTarget(self, action: #selector(tappedMemoButton), for: .touchDown)
            }
        }

        stride(from: 1, through: 9, by: 1).forEach { number in
            numberStackView.addArrangedSubview(NumberButton(number: number))
        }
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
            numberStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    @objc private func tappedBackBarButton(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
        if let encoded = try? JSONEncoder().encode(sudoku) {
            UserDefaults.standard.setValue(encoded, forKey: "Sudoku")
        }
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

    @objc private func tappedMemoButton(_ sender: AbilityButton) {
        sender.toggleMemo()
    }

    @objc func runTime() {
        time += 1
        timerView.updateContent(by: .timer(content: time))
    }

    private func requestSudoku() {
        Networking().loadData { result in
            switch result {
            case .success(let sudokuData):
                guard let sudokuData else { return }
                self.sudoku = Sudoku(data: sudokuData)

                DispatchQueue.main.async {
                    self.boardView.updateAll(sudokuData.problem)
                    self.difficultyView.updateContent(by: .difficulty(content: sudokuData.difficulty.discription))
                }
            case .failure(let failure):
                print(failure)
            }
        }
    }
}

extension GameViewController: SectionViewDelegate {
    func cellButtonTapped(_ button: CellButton) {
        cursor = button.indexPath

        boardView.paint(associated: button)
    }
}
