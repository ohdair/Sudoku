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

    typealias Board = [[SudokuItem]]

    struct Input {
        var data: Observable<SudokuData>
        var board: Observable<Board>
        var isOnMemo: Driver<Bool>
        var cellButtonTapped: Driver<IndexPath>
        var numberButtonTapped: Driver<Int>
        var eraseTrigger: Driver<Void>
        var reformTrigger: Driver<Void>
    }

    struct Output {
        var board: Driver<Board>
        var cursor: Driver<IndexPath?>
        var cursorState: Driver<CellButton.State>
        var associatedMistake: Driver<[IndexPath]>
        var associatedIndexPaths: Driver<[IndexPath]>
        var associatedNumbers: Driver<[IndexPath]>
        var mistakeTrigger: Driver<Void>
        var endGameTrigger: Driver<Void>
    }

    private let problem = BehaviorRelay<[[Int]]>(value: [])
    private let solution = BehaviorRelay<[[Int]]>(value: [])
    private let board = BehaviorRelay<Board>(value: [])
    private let cursor = BehaviorRelay<IndexPath?>(value: nil)
    private let cursorState = BehaviorRelay<CellButton.State>(value: .problem)
    private let isOnMemo = BehaviorRelay<Bool>(value: false)

    private let associatedIndexPaths = BehaviorRelay<[IndexPath]>(value: [])
    private let associatedNumbers = BehaviorRelay<[IndexPath]>(value: [])

    private let disposeBag = DisposeBag()

    func transform(input: Input) -> Output {
        bind(to: input)

        let updatedBoardToErase = input.eraseTrigger
            .filter { _ in self.isProblemCursor() == false }
            .compactMap { _ in self.cursor.value }
            .map { cursor in
                return 0...8 ~= cursor.section && 0...8 ~= cursor.item
            }
            .filter { $0 }
            .map { _ in SudokuItem() }
            .map { self.updatedBoard(to: $0, of: self.cursor.value!) }

        let updatedBoardToMemo = input.numberButtonTapped
            .filter { _ in self.isProblemCursor() == false }
            .filter { _ in self.isOnMemo.value }
            .map { self.updatedMemoOfCursor(to: $0) }
            .map { self.updatedBoard(to: $0, of: self.cursor.value!) }

        let updatedBoardToNumber = input.numberButtonTapped
            .filter { _ in self.isProblemCursor() == false }
            .filter { _ in !self.isOnMemo.value }
            .map { self.updatedNumberOfCursor(to: $0) }
            .map { self.updatedBoard(to: $0, of: self.cursor.value!) }

        input.board
            .withLatestFrom(cursor)
            .compactMap { $0 }
            .subscribe { cursor in
                self.cursor.accept(cursor)
                self.acceptAssociatedIndexPaths(with: cursor)
                self.acceptAssociatedNumbers(with: cursor)
            }
            .disposed(by: disposeBag)

        input.cellButtonTapped
            .drive { cursor in
                self.cursor.accept(cursor)
                self.acceptAssociatedIndexPaths(with: cursor)
                self.acceptAssociatedNumbers(with: cursor)
            }
            .disposed(by: disposeBag)

        let associatedMistake = Observable.merge(input.cellButtonTapped.asObservable(),
                                                 input.board.withLatestFrom(cursor).compactMap({ $0 }))
            .map { _ in self.associatedMistake() }
            .asDriver(onErrorJustReturn: [])

        let mistakeTrigger = updatedBoardToNumber
            .map { _ in self.associatedMistake() }
            .map { !$0.isEmpty }
            .filter { $0 }
            .map { _ in }

        let endGameTrigger = updatedBoardToNumber
            .map { self.isEnd($0) }
            .filter { $0 }
            .map { _ in () }

        associatedMistake
            .map { !$0.isEmpty }
            .map { self.cursorState(using: $0) }
            .drive(cursorState)
            .disposed(by: disposeBag)

        return Output(
            board: Driver.merge(updatedBoardToErase, updatedBoardToMemo, updatedBoardToNumber),
            cursor: cursor.asDriver(),
            cursorState: cursorState.asDriver(),
            associatedMistake: associatedMistake,
            associatedIndexPaths: associatedIndexPaths.asDriver(),
            associatedNumbers: associatedNumbers.asDriver(),
            mistakeTrigger: mistakeTrigger,
            endGameTrigger: endGameTrigger
        )
    }

    private func bind(to input: Input) {
        input.data
            .map { $0.problem }
            .bind(to: problem)
            .disposed(by: disposeBag)

        input.data
            .map { $0.solution }
            .bind(to: solution)
            .disposed(by: disposeBag)

        input.board
            .bind(to: board)
            .disposed(by: disposeBag)

        input.cellButtonTapped
            .drive(cursor)
            .disposed(by: disposeBag)

        input.isOnMemo
            .drive(isOnMemo)
            .disposed(by: disposeBag)

        input.reformTrigger
            .map { _ in nil }
            .drive(cursor)
            .disposed(by: disposeBag)
    }

    private func updatedMemoOfCursor(to number: Int) -> SudokuItem {
        let cursor = self.cursor.value!
        let item = self.board.value.sudokuItem(of: cursor)

        return item.updated(memo: number)
    }

    private func updatedNumberOfCursor(to number: Int) -> SudokuItem {
        let cursor = self.cursor.value!
        let item = self.board.value.sudokuItem(of: cursor)

        return item.updated(number: number)
    }

    private func updatedBoard(to sudokuItem: SudokuItem, of cursor: IndexPath) -> Board {
        let row = cursor.row()
        let column = cursor.column()

        var newBoard = board.value
        newBoard[row][column] = sudokuItem

        board.accept(newBoard)

        return newBoard
    }

    private func isProblemCursor() -> Bool {
        guard let cursor = cursor.value else {
            return false
        }

        let row = cursor.row()
        let column = cursor.column()
        var isProblem: Bool

        if problem.value[row][column] == 0 {
            isProblem = false
        } else {
            isProblem = true
            self.cursorState.accept(.problem)
        }

        return isProblem
    }

    private func cursorState(using isMistake: Bool) -> CellButton.State {
        var state: CellButton.State

        if self.isProblemCursor() {
            state = .problem
        } else if isMistake {
            state = .mistake
        } else {
            state = .selected
        }

        return state
    }

    private func isEnd(_ board: Board) -> Bool {
        for (boardRow, solutionRow) in zip(board, solution.value) {
            for (boardItem, solutionItem) in zip(boardRow, solutionRow) {
                guard boardItem.number == solutionItem else {
                    return false
                }
            }
        }

        return true
    }
}

extension BoardViewModel: IndexPathable {
    fileprivate func associatedMistake() -> [IndexPath] {
        let indexPaths = associatedIndexPaths.value
        let cursor = cursor.value!
        let numberOfCursor = board.value.sudokuItem(of: cursor).number

        return indexPaths.filter { indexPath in
            let item = board.value.sudokuItem(of: indexPath)
            let numberOfItem = item.number

            return numberOfItem != 0 && numberOfItem == numberOfCursor
        }
    }

    fileprivate func acceptAssociatedNumbers(with cursor: IndexPath) {
        let board = board.value
        let numberOfCursor = board.sudokuItem(of: cursor).number
        let indexPaths: [IndexPath] = board
            .compactMapMatrix { row, column, item in
                guard numberOfCursor != 0 && numberOfCursor == item.number else {
                    return nil
                }

                return self.indexPath(row: row, column: column)
            }
            .flatMap { $0 }
            .filter { $0 != cursor }

        self.associatedNumbers.accept(indexPaths)
    }

    fileprivate func acceptAssociatedIndexPaths(with indexPath: IndexPath) {
        let row = associatedRow(with: indexPath)
        let column = associatedColumn(with: indexPath)
        let section = associatedSection(with: indexPath)
        let indexPaths = row + column + section

        self.associatedIndexPaths.accept(indexPaths)
    }

    private func associatedRow(with indexPath: IndexPath) -> [IndexPath] {
        let row = indexPath.row()

        return stride(from: 0, to: 9, by: 1)
            .map { self.indexPath(row: row, column: $0) }
            .filter { $0 != indexPath }
    }

    private func associatedColumn(with indexPath: IndexPath) -> [IndexPath] {
        let column = indexPath.column()

        return stride(from: 0, to: 9, by: 1)
            .map { self.indexPath(row: $0, column: column) }
            .filter { $0 != indexPath }
    }

    private func associatedSection(with indexPath: IndexPath) -> [IndexPath] {
        return stride(from: 0, to: 9, by: 1)
            .map { IndexPath(item: $0, section: indexPath.section) }
            .filter { $0 != indexPath }
    }
}
