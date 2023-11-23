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
        stackView.distribution = .equalCentering
        return stackView
    }()

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

    var timer: Timer?
    var time = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

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
        view.addSubview(abilityStackView)
        view.addSubview(numberStackView)

        informationStackView.translatesAutoresizingMaskIntoConstraints = false
        abilityStackView.translatesAutoresizingMaskIntoConstraints = false
        numberStackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            informationStackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            informationStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            informationStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            abilityStackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            abilityStackView.bottomAnchor.constraint(equalTo: numberStackView.topAnchor, constant: -30),
            abilityStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            numberStackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            numberStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30),
            numberStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    @objc private func tappedBackBarButton(_ sender: UIBarButtonItem) {
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

    @objc private func tappedMemoButton(_ sender: AbilityButton) {
        sender.toggleMemo()
    }

    @objc func runTime() {
        time += 1
        timerView.updateContent(by: .timer(content: time))
    }
}
