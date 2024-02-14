//
//  InformationStackView.swift
//  Sudoku
//
//  Created by 박재우 on 12/5/23.
//

import UIKit

class InformationStackView: UIStackView {
    private let difficultyView = InformationView(type: .difficulty)
    private let mistakeView = InformationView(type: .mistake)
    private let timerView = InformationView(type: .timer)

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

    func label(of information: InformationView.Information) -> UILabel {
        switch information {
        case .difficulty:
            difficultyView.contentLabel
        case .mistake:
            mistakeView.contentLabel
        case .timer:
            timerView.contentLabel
        }
    }
}
