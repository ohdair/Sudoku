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
    private(set) var mistake: Int = 0
    private(set) var board: [[SudokuItem]]
    var history: [[[SudokuItem]]] = []
    private(set) var cursor: IndexPath?
    var isOnMemo: Bool = false
    var isOverMistake: Bool {
        get { mistake > 2 ? true : false }
    }

    init(data: SudokuData) {
        self.data = data
        self.board = data.problem.mapMatrix { number in
            SudokuItem(number: number)
        }
        self.history.append(self.board)
    }

    mutating func setCursor(to indexPath: IndexPath) {
        cursor = indexPath
    }

    mutating func update(number: Int, indexPath: IndexPath) {
        let row = indexPath.row()
        let column =  indexPath.column()

        if isOnMemo {
            board[row][column].updateMemo(to: number)
        } else {
            board[row][column].updateNumber(to: number)
        }
    }

    mutating func update(item: SudokuItem, indexPath: IndexPath) {
        let row = indexPath.row()
        let column =  indexPath.column()

        board[row][column] = item
    }

    mutating func erase(indexPath: IndexPath) {
        let row = indexPath.row()
        let column =  indexPath.column()

        board[row][column] = SudokuItem()
    }

    func item(of indexPath: IndexPath) -> SudokuItem {
        let row = indexPath.row()
        let column =  indexPath.column()

        return board[row][column]
    }

    func isMistake(indexPath: IndexPath) -> Bool {
        return !mistake(indexPath: indexPath).isEmpty
    }

    func isProblem(indexPath: IndexPath) -> Bool {
        let row = indexPath.row()
        let column =  indexPath.column()

        return data.problem[row][column] != 0
    }

    mutating func increaseMistake() {
        guard mistake < 3 else { return }

        mistake += 1
    }
}

extension Sudoku: IndexPathable {
    func mistake(indexPath: IndexPath) -> [IndexPath] {
        let number = item(of: indexPath).number

        return associatedIndexPaths(indexPath: indexPath)
            .filter { number != 0 && item(of: $0).number == number }
    }

    func associatedNumbers(indexPath: IndexPath) -> [IndexPath] {
        let number = item(of: indexPath).number
        guard number != 0 else { return [] }

        return board
            .compactMapMatrix { row, column, element in
                number == element.number ? self.indexPath(row: row, column: column) : nil
            }
            .flatMap { $0 }
    }

    func associatedIndexPaths(indexPath: IndexPath) -> [IndexPath] {
        let row = associatedRow(indexPath: indexPath)
        let column = associatedColumn(indexPath: indexPath)
        let section = associatedSection(indexPath: indexPath)

        return row + column + section
    }

    private func associatedRow(indexPath: IndexPath) -> [IndexPath] {
        let row = indexPath.row()

        return stride(from: 0, to: 9, by: 1)
            .map { self.indexPath(row: row, column: $0) }
            .filter { $0 != indexPath }
    }

    private func associatedColumn(indexPath: IndexPath) -> [IndexPath] {
        let column = indexPath.column()

        return stride(from: 0, to: 9, by: 1)
            .map { self.indexPath(row: $0, column: column) }
            .filter { $0 != indexPath }
    }

    private func associatedSection(indexPath: IndexPath) -> [IndexPath] {
        return stride(from: 0, to: 9, by: 1)
            .map { IndexPath(item: $0, section: indexPath.section) }
            .filter { $0 != indexPath }
    }
}
