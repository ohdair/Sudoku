//
//  NumberButton.swift
//  Sudoku
//
//  Created by 박재우 on 11/21/23.
//

import UIKit

class NumberButton: UIButton {
    private let numberLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 30, weight: .bold)
        label.textColor = .mainColor
        label.textAlignment = .center
        return label
    }()
    private(set) var number: Int

    init(number: Int) {
        self.number = number
        super.init(frame: .zero)

        numberLabel.text = String(describing: number)

        setLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setLayout() {
        addSubview(numberLabel)

        numberLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            numberLabel.topAnchor.constraint(equalTo: self.topAnchor),
            numberLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            numberLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            numberLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
}
