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
        var sudoku: Observable<Sudoku>
        var sudokuItem: Observable<SudokuItem>
        var cellButtonTapped: Observable<IndexPath>
    }

    struct Output {
        var isMistake: Observable<Bool>
        var associatedMistake: Observable<[IndexPath]>
        var associatedIndexPaths: Observable<[IndexPath]>
        var associatedNumbers: Observable<[IndexPath]>
    }

    private let disposeBag = DisposeBag()

    func transform(input: Input) -> Output {
        let isMistake = isMistake(
            cellButtonTapped: input.cellButtonTapped,
            in: input.sudoku
        )

        let associatedMistake = mistakeIndexPath(
            cellButtonTapped: input.cellButtonTapped,
            in: input.sudoku
        )

        let associatedIndexPaths = associatedIndexPaths(
            of: input.cellButtonTapped,
            in: input.sudoku
        )

        let associatedNumbers = associatedNumbers(
            of: input.cellButtonTapped,
            in: input.sudoku
        )
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
            isMistake: isMistake,
            associatedMistake: associatedMistake,
            associatedIndexPaths: associatedIndexPaths,
            associatedNumbers: associatedNumbers
        )
    }

    // MARK: - 임시로 지움, 필요할 시 다시 생성
//    func updateSudoku(to sudoku: Observable<Sudoku>) {
//        sudoku
//            .subscribe { sudoku in
//                self.sudoku.onNext(sudoku)
//            }
//            .disposed(by: disposeBag)
//    }
//
//    func updateCursor(to cellButtonTapped: Driver<IndexPath>) {
//        cellButtonTapped
//            .drive { cursor in
//                self.cursor.onNext(cursor)
//            }
//            .disposed(by: disposeBag)
//    }
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
