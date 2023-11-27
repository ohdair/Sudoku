//
//  BoardView.swift
//  Sudoku
//
//  Created by 박재우 on 11/27/23.
//

import UIKit

class BoardView: UIView {
    private(set) var sections = [SectionView]()

    init() {
        super.init(frame: .zero)

        sections = stride(from: 0, to: 9, by: 1).map { section in
            SectionView(section: section)
        }

        setUI()
        setLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUI() {
        layer.borderColor = UIColor.systemGray.cgColor
        layer.borderWidth = 2
    }

    private func setLayout() {
        for (index, sectionView) in sections.enumerated() {
            addSubview(sectionView)

            sectionView.translatesAutoresizingMaskIntoConstraints = false

            let topAnchor = index / 3 == 0 ? topAnchor : sections[index - 3].bottomAnchor
            let leadingAnchor = index % 3 == 0 ? leadingAnchor : sections[index % 3 - 1].trailingAnchor

            NSLayoutConstraint.activate([
                sectionView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1 / 3),
                sectionView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1 / 3),
                sectionView.topAnchor.constraint(equalTo: topAnchor),
                sectionView.leadingAnchor.constraint(equalTo: leadingAnchor)
            ])
        }
    }
}
