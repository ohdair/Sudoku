//
//  Sudoku.swift
//  Sudoku
//
//  Created by 박재우 on 11/28/23.
//

import Foundation

struct Sudoku {
    var data: SudokuData
    var time: Int = 0
    var mistake: Int = 0
    var solving: [[SudokuItem]]
    var history: [[[SudokuItem]]] = []

    init(data: SudokuData, time: Int, mistake: Int, solving: [[SudokuItem]], history: [[[SudokuItem]]]) {
        self.data = data
        self.time = time
        self.mistake = mistake
        self.history = history
        self.solving = data.problem.map { row in
            row.map { SudokuItem(number: $0) }
        }
    }
}
