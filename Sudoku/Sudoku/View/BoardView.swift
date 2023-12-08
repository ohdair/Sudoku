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
    func paint(to indexPath: IndexPath, into state: CellButton.State) {
        cellButton(of: indexPath).paintedBackground(according: state)
    }

    func paint(to indexPaths: [IndexPath], into state: CellButton.State) {
        indexPaths
            .forEach {
                cellButton(of: $0).paintedBackground(according: state)
            }
    }

    func paintText(to indexPath: IndexPath, into state: CellButton.State) {
        cellButton(of: indexPath).paintedTextColor(according: state)
    }

    func paintedReset() {
        sections
            .flatMap { $0.buttons }
            .forEach { $0.paintedBackground(according: .problem) }
    }

    func updateAll(_ board: [[SudokuItem]]) {
        conform(board) { (indexPath, item) in
            let cellButton = cellButton(of: indexPath)
            if item.number != 0 {
                cellButton.number(to: item.number)
            } else {
                cellButton.memo(to: item.memo)
            }
        }
    }

    func updateMemo(_ memo: [Bool], indexPath: IndexPath) {
        let button = cellButton(of: indexPath)
        button.memo(to: memo)
    }

    func updateNumber(_ number: Int, indexPath: IndexPath) {
        let button = cellButton(of: indexPath)
        button.number(to: number)
    }

    func cellButton(of indexPath: IndexPath) -> CellButton {
        return sections[indexPath.section].buttons[indexPath.row]
    }
}
