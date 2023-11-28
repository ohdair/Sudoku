//
//  Cursor.swift
//  Sudoku
//
//  Created by 박재우 on 11/28/23.
//

import Foundation

struct Cursor {
    var row: Int
    var column: Int

    func transform() -> IndexPath {
        let item = row % 3 * 3 + column % 3
        let section = row / 3 * 3 + column / 3
        return IndexPath(item: item, section: section)
    }
}
