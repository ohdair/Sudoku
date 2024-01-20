//
//  BoardViewModel.swift
//  Sudoku
//
//  Created by 박재우 on 1/15/24.
//

import Foundation
import RxSwift
import RxCocoa

final class BoardViewModel: ViewModelType {

    struct Input {
        var board: Observable<[[SudokuItem]]>
        var isOnMemo: Driver<Bool>
        var cellButtonTapped: Driver<IndexPath>
        var numberButtonTapped: Driver<Int>
    }

    struct Output {
        var board: Driver<[[SudokuItem]]>
        var isMistake: Driver<Bool>
        var cursor: Driver<IndexPath>
        var associatedMistake: Driver<[IndexPath]>
        var associatedIndexPaths: Driver<[IndexPath]>
        var associatedNumbers: Driver<[IndexPath]>
    }

    private let board = BehaviorRelay<[[SudokuItem]]>(value: [])
    private let cursor = BehaviorRelay<IndexPath?>(value: nil)
    private let isOnMemo = BehaviorRelay<Bool>(value: false)
    private let disposeBag = DisposeBag()

    func transform(input: Input) -> Output {
        input.board
            .subscribe { board in
                self.board.accept(board)
            }
            .disposed(by: disposeBag)

        input.cellButtonTapped
            .drive { indexPath in
                self.cursor.accept(indexPath)
            }
            .disposed(by: disposeBag)

        input.isOnMemo
            .drive { isMemo in
                self.isOnMemo.accept(isMemo)
            }
            .disposed(by: disposeBag)

        let itemOfCursorDriver = item(of: input.cellButtonTapped)
        let updatedMemo = updatedMemo(to: itemOfCursorDriver, into: input.numberButtonTapped)
        let updatedNumber = updatedNumber(to: itemOfCursorDriver, into: input.numberButtonTapped)

        Driver.merge(updatedMemo, updatedNumber)
            .withLatestFrom(input.cellButtonTapped) { sudokuItem, cursor in
                self.updatedBoard(to: sudokuItem, of: cursor)
            }
            .drive { updatedBoard in
                self.board.accept(updatedBoard)
            }
            .disposed(by: disposeBag)

        // MARK: - cursor의 숫자가 업데이트되면(메모 X) 해당 커서와 관련된 칠하는 Driver 생성
        let paintTrigger = Driver.merge(itemOfCursorDriver, updatedNumber)

        let associatedIndexPaths = paintTrigger
            .withLatestFrom(self.cursor.asDriver())
            .compactMap { $0 }
            .map { cursor in
                self.associatedIndexPaths(indexPath: cursor)
            }

        let associatedMistake = paintTrigger
            .withLatestFrom(associatedIndexPaths) { item, indexPaths in
                self.associatedMistake(indexPaths: indexPaths, with: item.number)
            }

        let isMistake = associatedMistake.map { !$0.isEmpty }

        let associatedNumbers = paintTrigger
            .withLatestFrom(self.board.asDriver()) { item, board in
                self.associatedNumbers(board: board, with: item.number)
            }

        return Output(
            board: board.asDriver(),
            isMistake: isMistake,
            cursor: input.cellButtonTapped,
            associatedMistake: associatedMistake,
            associatedIndexPaths: associatedIndexPaths,
            associatedNumbers: associatedNumbers
        )
    }

    private func item(of indexPath: Driver<IndexPath>) -> Driver<SudokuItem> {
        return indexPath
            .compactMap { $0 }
            .withLatestFrom(board.asDriver()) { cursor, board in
                board.sudokuItem(of: cursor)
            }
    }

    private func updatedMemo(to item: Driver<SudokuItem>, into number: Driver<Int>) -> Driver<SudokuItem> {
        number
            .filter { _ in self.isOnMemo.value }
            .withLatestFrom(item) { number, sudokuItem in
                sudokuItem.updated(memo: number)
            }
    }

    private func updatedNumber(to item: Driver<SudokuItem>, into number: Driver<Int>) -> Driver<SudokuItem> {
        number
            .filter { _ in !self.isOnMemo.value }
            .withLatestFrom(item) { number, SudokuItem in
                SudokuItem.updated(number: number)
            }
    }

    private func updatedBoard(to sudokuItem: SudokuItem, of cursor: IndexPath) -> [[SudokuItem]] {
        let row = cursor.row()
        let column = cursor.column()

        var board = board.value
        board[row][column] = sudokuItem

        return board
    }

    private func associatedMistake(indexPaths: [IndexPath], with number: Int) -> [IndexPath] {
        indexPaths.filter { indexPath in
            let item = board.value.sudokuItem(of: indexPath)
            let numberOfItem = item.number

            return numberOfItem != 0 && numberOfItem == number
        }
    }

    private func associatedNumbers(board: [[SudokuItem]], with number: Int) -> [IndexPath] {
        board.compactMapMatrix { row, column, item in
            guard number != 0 && item.number == number else { return nil }

            return self.indexPath(row: row, column: column)
        }
        .flatMap { $0 }
    }
}

extension BoardViewModel: IndexPathable {
    fileprivate func associatedIndexPaths(indexPath: IndexPath) -> [IndexPath] {
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
