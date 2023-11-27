//
//  SectionView.swift
//  Sudoku
//
//  Created by 박재우 on 11/27/23.
//

import UIKit

protocol SectionViewDelegate: AnyObject {
    func cellButtonTapped(_ button: CellButton)
}

class SectionView: UIView {
    weak var delegate: SectionViewDelegate?
    private let section: Int
    private var buttons = [CellButton]()

    init(section: Int) {
        self.section = section

        super.init(frame: .zero)

        stride(from: 0, to: 9, by: 1).forEach { item in
            let button = CellButton(item: item, section: section)
            button.addTarget(self, action: #selector(cellButtonTapped), for: .touchDown)
            buttons.append(button)
        }

        setUI()
        setLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUI() {
        layer.borderColor = UIColor.systemGray3.cgColor
        layer.borderWidth = 1
    }

    private func setLayout() {
        for (index, button) in buttons.enumerated() {
            addSubview(button)

            button.translatesAutoresizingMaskIntoConstraints = false

            let topAnchor = index / 3 == 0 ? topAnchor : buttons[index - 3].bottomAnchor
            let leadingAnchor = index % 3 == 0 ? leadingAnchor : buttons[index % 3 - 1].trailingAnchor

            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1 / 3),
                button.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1 / 3),
                button.topAnchor.constraint(equalTo: topAnchor),
                button.leadingAnchor.constraint(equalTo: leadingAnchor)
            ])
        }
    }

    @objc private func cellButtonTapped(_ sender: CellButton) {
        delegate?.cellButtonTapped(sender)
    }
}
