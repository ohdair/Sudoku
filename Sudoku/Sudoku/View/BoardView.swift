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

extension BoardView: IndexPathable {
    func paint(associated button: CellButton) {
        paintedReset()

        let buttonsAssociatedCursor = buttons(associated: button)
        buttonsAssociatedCursor.forEach { $0.paintedBackground(according: .associatedCursor) }

        let numbers = numbers(associated: button)
        numbers.forEach { $0.paintedBackground(according: .associatedNumber) }

        let mistakeButtons = buttonsAssociatedCursor.filter { button.number != nil && $0.number == button.number }
        mistakeButtons.forEach { $0.paintedBackground(according: .mistake) }

        if !mistakeButtons.isEmpty {
            button.paintedTextColor(according: .mistake)
        }

        button.paintedBackground(according: .selected)
    }

    func paintedReset() {
        sections
            .flatMap { $0.buttons }
            .forEach { $0.paintedBackground(according: .normal) }
    }

    private func buttons(associated button: CellButton) -> [CellButton] {
        let row = row(associated: button.indexPath)
        let column = column(associated: button.indexPath)
        let section = section(associated: button.indexPath)
        return row + column + section
    }

    private func row(associated indexPath: IndexPath) -> [CellButton] {
        let sectionViews = sections.filter { $0.section / 3 == indexPath.section / 3 }

        return sectionViews
            .flatMap {$0.buttons }
            .filter { $0.indexPath != indexPath && $0.indexPath.item / 3 == indexPath.item / 3 }
    }

    private func column(associated indexPath: IndexPath) -> [CellButton] {
        let sectionViews = sections.filter { $0.section % 3 == indexPath.section % 3 }

        return sectionViews
            .flatMap { $0.buttons }
            .filter { $0.indexPath != indexPath && $0.indexPath.item % 3 == indexPath.item % 3 }
    }

    private func section(associated indexPath: IndexPath) -> [CellButton] {
        let buttons = sections[indexPath.section].buttons

        return buttons.filter { $0.indexPath != indexPath }
    }

    private func numbers(associated button: CellButton) -> [CellButton] {
        return sections
            .flatMap { $0.buttons }
            .filter { button.number != nil && $0.indexPath != button.indexPath && $0.number == button.number }
    }

    func updateAll(_ board: [[SudokuItem]]) {
        conform(board) { (indexPath, item) in
            let cellButton = cellButton(item: indexPath.item, section: indexPath.section)
            if item.number != 0 {
                cellButton.number(to: item.number)
            } else {
                cellButton.memo(to: item.memo)
            }
        }
    }

    func updateMemo(_ memo: [Bool], indexPath: IndexPath) {
        let button = cellButton(item: indexPath.item, section: indexPath.section)
        button.memo(to: memo)
    }

    func updateNumber(_ number: Int, indexPath: IndexPath) {
        let button = cellButton(item: indexPath.item, section: indexPath.section)
        button.number(to: number)
    }

    private func cellButton(item: Int, section: Int) -> CellButton {
        return sections[section].buttons[item]
    }
}
