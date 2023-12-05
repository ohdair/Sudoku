//
//  IndexPath.swift
//  Sudoku
//
//  Created by 박재우 on 12/5/23.
//

import Foundation

extension IndexPath {
    func row() -> Int {
        self.section / 3 * 3 + self.item / 3
    }

    func column() -> Int {
        self.section % 3 * 3 + self.item % 3
    }
}
