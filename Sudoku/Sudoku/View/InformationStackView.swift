//
//  InformationStackView.swift
//  Sudoku
//
//  Created by 박재우 on 12/5/23.
//

import UIKit

class InformationStackView: UIStackView {
    private let difficultyView = InformationView()
    private let mistakeView = InformationView()
    private let timerView = InformationView()

    override init(frame: CGRect) {
        super.init(frame: .zero)

        setUI()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUI() {
        addArrangedSubview(difficultyView)
        addArrangedSubview(mistakeView)
        addArrangedSubview(timerView)

        distribution = .fillEqually
    }

    func configure(_ information: InformationView.Information) {
        switch information {
        case .difficulty:
            difficultyView.updateContent(by: information)
        case .mistake:
            mistakeView.updateContent(by: information)
        case .timer:
            timerView.updateContent(by: information)
        }
    }
}
