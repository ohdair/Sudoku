//
//  AlertView.swift
//  Sudoku
//
//  Created by 박재우 on 12/10/23.
//

import UIKit

final class AlertView: UIView {

    private let stackView = UIStackView()

    let titleLabel = UILabel()
    let continueButton = AlertButton(type: .continue)
    let restartButton = AlertButton(type: .restart)
    let newGameButton = AlertButton(type: .new)
    let quitGameButton = AlertButton(type: .quit)

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
    }

    private func setLayout() {
        addSubview(titleLabel)
        addSubview(stackView)

        stackView.addArrangedSubview(continueButton)
        stackView.addArrangedSubview(restartButton)
        stackView.addArrangedSubview(newGameButton)
        stackView.addArrangedSubview(quitGameButton)

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

}

extension AlertView {

    enum Alert {
        case pause
        case back
        case overMistake
        case error

        var title: String {
            switch self {
            case .pause:
                "일시정지"
            case .back:
                "게임을 종료하시겠습니까?"
            case .overMistake:
                "실수를 초과하였습니다."
            case .error:
                "네트워크 문제가 발생하였습니다."
            }
        }

        var titleFontSize: CGFloat {
            switch self {
            case .pause:
                26
            default:
                20
            }
        }
    }

}
