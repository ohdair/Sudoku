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
        var isMistake: Observable<Bool>
        var associatedMistake: Observable<[IndexPath]>
        var associatedIndexPaths: Observable<[IndexPath]>
        var associatedNumbers: Observable<[IndexPath]>
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

        let sudokuItemDriver = cursor.asDriver()
            .compactMap { $0 }
            .withLatestFrom(board.asDriver()) { cursor, board in
                board.sudokuItem(of: cursor)
            }

        input.numberButtonTapped
            .withLatestFrom(sudokuItemDriver) { number, sudokuItem in
                if self.isOnMemo.value {
                    sudokuItem.updated(memo: number)
                } else {
                    sudokuItem.updated(number: number)
                }
            }
            .drive { sudokuItem in
                self.updateBoard(to: sudokuItem)
            }
            .disposed(by: disposeBag)



//        let isMistake = isMistake(
//            cellButtonTapped: input.cellButtonTapped,
//            in: input.sudoku
//        )
//
//        let associatedMistake = mistakeIndexPath(
//            cellButtonTapped: input.cellButtonTapped,
//            in: input.sudoku
//        )
//
//        let associatedIndexPaths = associatedIndexPaths(
//            of: input.cellButtonTapped,
//            in: input.sudoku
//        )
//
//        let associatedNumbers = associatedNumbers(
//            of: input.cellButtonTapped,
//            in: input.sudoku
//        )

        // MARK: - sudokuItem 업데이트 되면 sudoku update
//        Driver.combineLatest(input.cellButtonTapped, input.sudokuItem)
//            .drive { cursor, sudokuItem in
//                suoku.
//
//            }

        /**
         1. 셀 버튼 클릭
         2. 커서 업데이트
         3. 관련 셀 버튼 paint
            3 - 1. 커서 셀 버튼
            3 - 2. 세로, 가로, 구역 셀 버튼
         4. isMistake? (커서의 번호와 관련 셀 버튼의 번호가 있는 지 확인)
            4 - Y. 관련 mistake 셀 버튼 paint
            4 - N. 동작 하지 않음
         **/

        return Output(
            board: board.asDriver(),
            isMistake: BehaviorSubject(value: false),
            associatedMistake: BehaviorSubject(value: [IndexPath]()),
            associatedIndexPaths: BehaviorSubject(value: [IndexPath]()),
            associatedNumbers: BehaviorSubject(value: [IndexPath]())
//            isMistake: isMistake,
//            associatedMistake: associatedMistake,
//            associatedIndexPaths: associatedIndexPaths,
//            associatedNumbers: associatedNumbers
        )
    }

    private func updateBoard(to sudokuItem: SudokuItem) {
        guard let cursor = cursor.value else { return }
        let row = cursor.row()
        let column = cursor.column()

        var board = board.value
        board[row][column] = sudokuItem

        self.board.accept(board)
    }

    private func isMistake(
        cellButtonTapped: Observable<IndexPath>,
        in sudoku: Observable<Sudoku>
    ) -> Observable<Bool> {
        Observable.combineLatest(sudoku, cellButtonTapped)
            .map { sudoku, cursor in
                sudoku.isMistake(indexPath: cursor)
            }
    }

    private func mistakeIndexPath(
        cellButtonTapped: Observable<IndexPath>,
        in sudoku: Observable<Sudoku>
    ) -> Observable<[IndexPath]> {
        Observable.combineLatest(sudoku, cellButtonTapped)
            .filter { sudoku, cursor in
                sudoku.isMistake(indexPath: cursor)
            }
            .map { sudoku, cursor in
                sudoku.mistake(indexPath: cursor)
            }
    }

    private func associatedIndexPaths(
        of cellButtonTapped: Observable<IndexPath>,
        in sudoku: Observable<Sudoku>
    ) -> Observable<[IndexPath]> {
        Observable.combineLatest(sudoku, cellButtonTapped)
            .map { sudoku, cursor in
                sudoku.associatedIndexPaths(indexPath: cursor)
            }
    }

    private func associatedNumbers(
        of cellButtonTapped: Observable<IndexPath>,
        in sudoku: Observable<Sudoku>
    ) -> Observable<[IndexPath]> {
        Observable.combineLatest(sudoku, cellButtonTapped)
            .map { sudoku, cursor in
                sudoku.associatedNumbers(indexPath: cursor)
            }
    }
}
