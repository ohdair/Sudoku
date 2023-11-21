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

    private var isTimerRun: Bool = true

    private var abilityStackView = {
        let stackView = UIStackView()
        stackView.distribution = .equalCentering
        return stackView
    }()

    private var numberStackView = {
        let stackView = UIStackView()
        stackView.distribution = .equalCentering
        return stackView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setUI()
        setLayout()

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
        view.addSubview(abilityStackView)
        view.addSubview(numberStackView)

        abilityStackView.translatesAutoresizingMaskIntoConstraints = false
        numberStackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            abilityStackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            abilityStackView.heightAnchor.constraint(equalToConstant: 60),
            abilityStackView.bottomAnchor.constraint(equalTo: numberStackView.topAnchor, constant: -30),
            abilityStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            numberStackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            numberStackView.heightAnchor.constraint(equalToConstant: 60),
            numberStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30),
            numberStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    @objc private func tappedBackBarButton(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }

    @objc private func tappedPauseBarButton(_ sender: UIBarButtonItem) {
        isTimerRun.toggle()
        pauseBarButtonItem.image = isTimerRun ? UIImage(systemName: "pause.circle") : UIImage(systemName: "play.circle")
    }

    @objc private func tappedMemoButton(_ sender: AbilityButton) {
        sender.toggleMemo()
    }
}
