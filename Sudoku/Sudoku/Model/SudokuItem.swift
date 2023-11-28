//
//  SudokuItem.swift
//  Sudoku
//
//  Created by 박재우 on 11/28/23.
//

import Foundation

struct SudokuItem: Codable {
    var number: Int = 0
    var memo: [Bool] = Array(repeating: false, count: 9)
}
