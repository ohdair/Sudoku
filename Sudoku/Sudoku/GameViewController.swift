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

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setUI()
        setLayout()

        for ability in AbilityButton.Ability.allCases {
            let abilityButton = AbilityButton(of: ability)
            abilityStackView.addArrangedSubview(abilityButton)

            if ability == .memo {
                abilityButton.addTarget(self, action: #selector(tappedMemoButton), for: .touchDown)
            }
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

        abilityStackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            abilityStackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            abilityStackView.heightAnchor.constraint(equalToConstant: 60),
            abilityStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30),
            abilityStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
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
