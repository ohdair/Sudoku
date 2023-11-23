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

    private var informationStackView = {
        let stackView = UIStackView()
        stackView.distribution = .equalCentering
        return stackView
    }()

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

        InformationView.Information.allCases.forEach { information in
            let informationView = InformationView(type: information)

            switch information {
            case .difficulty: informationView.updateContent("쉬움")
            case .mistake, .timer: informationView.updateContent(0)
            }
            informationStackView.addArrangedSubview(informationView)
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
        isTimerRun.toggle()
        pauseBarButtonItem.image = isTimerRun ? UIImage(systemName: "pause.circle") : UIImage(systemName: "play.circle")
    }

    @objc private func tappedMemoButton(_ sender: AbilityButton) {
        sender.toggleMemo()
    }
}
