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
    private(set) var board: [[SudokuItem]]
    var history: [[[SudokuItem]]] = []
    private(set) var cursor: IndexPath?
    var isOnMemo: Bool = false

    init(data: SudokuData) {
        self.data = data
        self.board = data.problem.map { row in
            row.map { SudokuItem(number: $0) }
        }
    }

    mutating func setCursor(to indexPath: IndexPath) {
        cursor = indexPath
    }

    mutating func update(number: Int, indexPath: IndexPath) {
        isOnMemo ? updateMemo(number, indexPath: indexPath) : updateNumber(number, indexPath: indexPath)
    }

    func item(indexPath: IndexPath) -> SudokuItem {
        let row = indexPath.row()
        let column =  indexPath.column()

        return board[row][column]
    }

    private mutating func updateMemo(_ number: Int, indexPath: IndexPath) {
        let row = indexPath.row()
        let column =  indexPath.column()

        board[row][column].updateMemo(to: number)
    }

    private mutating func updateNumber(_ number: Int, indexPath: IndexPath) {
        let row = indexPath.row()
        let column =  indexPath.column()

        board[row][column].updateNumber(to: number)
    }
}
