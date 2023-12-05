//
//  IndexPathable.swift
//  Sudoku
//
//  Created by 박재우 on 11/28/23.
//

import Foundation

protocol IndexPathable {
    func indexPath(row: Int, column: Int) -> IndexPath
    func conform(_ matrix: [[SudokuItem]], complition: (IndexPath, SudokuItem) -> Void)
}

extension IndexPathable {
    func indexPath(row: Int, column: Int) -> IndexPath {
        let item = row % 3 * 3 + column % 3
        let section = row / 3 * 3 + column / 3
        return IndexPath(item: item, section: section)
    }

    func conform(_ matrix: [[SudokuItem]], complition: (IndexPath, SudokuItem) -> Void) {
        matrix.enumerated().forEach { (i, row) in
            row.enumerated().forEach { (j, element) in
                complition(indexPath(row: i, column: j), element)
            }
        }
    }
}
