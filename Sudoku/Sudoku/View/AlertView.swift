//
//  AlertView.swift
//  Sudoku
//
//  Created by 박재우 on 12/10/23.
//

import UIKit

class AlertView: UIView {
    private let titleLabel = UILabel()
    private let stackView = UIStackView()

    let continueButton = GameButton(title: "게임 재개", reveralColor: true)
    let restartButton = GameButton(title: "다시 시작", reveralColor: true)
    let newGameButton = GameButton(title: "새 게임", reveralColor: true)
    let backGameButton = GameButton(title: "나가기", reveralColor: true)

    override init(frame: CGRect) {
        super.init(frame: .zero)

        setUI()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUI() {
        backgroundColor = .systemBackground
        layer.borderWidth = 1
        layer.borderColor = UIColor.mainColor.cgColor

        stackView.axis = .vertical
        stackView.spacing = 20

        backGameButton.configuration?.baseBackgroundColor = .red.withAlphaComponent(0.8)
        newGameButton.configuration?.baseBackgroundColor = .red.withAlphaComponent(0.8)
    }

    private func setLayout() {
        addSubview(titleLabel)
        addSubview(stackView)

        stackView.addArrangedSubview(continueButton)
        stackView.addArrangedSubview(restartButton)
        stackView.addArrangedSubview(newGameButton)
        stackView.addArrangedSubview(backGameButton)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: stackView.topAnchor),

            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.7),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -50)
        ])
    }

    func configure(type: AlertView.Alert) {
        switch type {
        case .pause:
            titleLabel.text = "일시정지"
            titleLabel.font = .systemFont(ofSize: 26, weight: .bold)
            continueButton.isHidden = false
            restartButton.isHidden = true
            newGameButton.isHidden = false
            backGameButton.isHidden = true
        case .back:
            titleLabel.text = "게임을 종료하시겠습니까?"
            titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
            continueButton.isHidden = false
            restartButton.isHidden = true
            newGameButton.isHidden = true
            backGameButton.isHidden = false
        case .overMistake:
            titleLabel.text = "실수를 초과하였습니다."
            titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
            continueButton.isHidden = true
            restartButton.isHidden = false
            newGameButton.isHidden = false
            backGameButton.isHidden = true
        case .error:
            titleLabel.text = "네트워크 문제가 발생하였습니다."
            titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
            continueButton.isHidden = true
            restartButton.isHidden = true
            newGameButton.isHidden = true
            backGameButton.isHidden = false
        }
    }
}

extension AlertView {
    enum Alert {
        case pause
        case back
        case overMistake
        case error
    }
}
