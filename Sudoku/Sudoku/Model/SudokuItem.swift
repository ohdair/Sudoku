//
//  SudokuItem.swift
//  Sudoku
//
//  Created by 박재우 on 11/28/23.
//

import Foundation

struct SudokuItem: Codable {
    private(set) var number: Int = 0
    private(set) var memo: [Bool] = Array(repeating: true, count: 9)

    mutating func updateMemo(to number: Int) {
        memo[number - 1].toggle()
    }

    mutating func updateNumber(to number: Int) {
        self.number = number
    }
}
