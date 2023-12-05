//
//  NumberStackView.swift
//  Sudoku
//
//  Created by 박재우 on 12/5/23.
//

import UIKit

class NumberStackView: UIStackView {
    override init(frame: CGRect) {
        super.init(frame: .zero)

        setUI()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUI() {
        stride(from: 1, through: 9, by: 1).forEach { number in
            addArrangedSubview(NumberButton(number: number))
        }

        distribution = .equalCentering
    }
}
