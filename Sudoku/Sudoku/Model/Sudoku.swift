//
//  Sudoku.swift
//  Sudoku
//
//  Created by 박재우 on 11/28/23.
//

import Foundation

struct Sudoku: Codable {

    var data: SudokuData
    var time: TimeInterval = 0
    var mistake: Int = 0
    var board: [[SudokuItem]]

    init(data: SudokuData) {
        self.data = data
        self.board = data.problem.mapMatrix { number in
            SudokuItem(number: number)
        }
    }

}
