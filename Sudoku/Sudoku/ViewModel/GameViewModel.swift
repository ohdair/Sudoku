//
//  GameViewModel.swift
//  Sudoku
//
//  Created by 박재우 on 1/3/24.
//

import Foundation
import RxSwift
import RxCocoa

final class GameViewModel: ViewModelType {

    struct Input {
        var viewDidLoad: Observable<Void>
        var timerTrigger: Driver<Void>
        var newGameTapped: Driver<Void>
        var reGameTapped: Driver<Void>
        var cellButtonTapped: Observable<IndexPath>
        var abilityButtonTapped: Observable<AbilityButton.Ability>
        var numberButtonTapped: Observable<Int>
    }

    struct Output {
        var informationOutput: InformationViewModel.Output
        var boardOutput: BoardViewModel.Output
        var sudoku: Observable<Sudoku>
        var loading: Driver<Bool>
        var alert: Observable<AlertView.Alert>
    }

    private let sudoku = PublishSubject<Sudoku>()
    private let mistakeTrigger = PublishSubject<Void>()
    private let fetching = PublishSubject<Bool>()
    private let disposeBag = DisposeBag()
    private let informationViewModel = InformationViewModel()

    private let isOnMemo = BehaviorSubject<Bool>(value: false)
    private let boardViewModel = BoardViewModel()

    private var savedSudoku: Sudoku?

    init(sudoku: Sudoku) {
        self.savedSudoku = sudoku
    }

    init() { }

    private func fetchSudoku() {
        LoadingIndicator.showLoading()

        Networking.request()
            .subscribe { sudokuData in
                let sudoku = Sudoku(data: sudokuData)
                self.sudoku.onNext(sudoku)
                LoadingIndicator.hideLoading()
            } onError: { error in
                LoadingIndicator.hideLoading()
                self.sudoku.onError(error)
            }
            .disposed(by: disposeBag)
    }

    private func reformSudoku() {
        sudoku
            .map { Sudoku(data: $0.data) }
            .subscribe { newSudoku in
                self.sudoku.onNext(newSudoku)
            }
            .disposed(by: disposeBag)
    }

    func transform(input: Input) -> Output {
        input.newGameTapped
            .drive { _ in
                self.fetchSudoku()
            }
            .disposed(by: disposeBag)

        input.reGameTapped
            .drive { _ in
                self.reformSudoku()
            }
            .disposed(by: disposeBag)

        input.viewDidLoad
            .subscribe { _ in
                if let savedSudoku = self.savedSudoku {
                    self.sudoku.onNext(savedSudoku)
                } else {
                    self.fetchSudoku()
                }
            }
            .disposed(by: disposeBag)

        let isMemo = input.abilityButtonTapped
            .filter { $0 == .memo }
            .scan(false) { isMemo, _ in
                !isMemo
            }
            .startWith(false)

        // MARK: - 테스팅 실패!! cursor - number 연결된 것으로
        //         combineLatest와 zip을 사용하면 문제가 발생
        //         "withLatestFrom"으로 변경하여 만들기

        // MARK: - 해당 커서의 sudokuItem을 불러오기
        let sudokuItemOfCursor = Observable
            .combineLatest(sudoku, input.cellButtonTapped)
            .map { sudoku, cursor in
                return sudoku.item(of: cursor)
            }

        // MARK: - 해당 커서의 업데이트된 sudokuItem을 가져오기
        let updatedSudokuItem = Observable.combineLatest(
            sudokuItemOfCursor,
            input.numberButtonTapped,
            isMemo
        )
            .map { sudokuItem, number, isMemo in
                if isMemo {
                    print("메모 업데이트")
                    return sudokuItem.updated(memo: number)
                } else {
                    print("숫자 업데이트")
                    return sudokuItem.updated(number: number)
                }
            }

        updatedSudokuItem
            .subscribe { sudokuItem in
                print("스도쿠 번호: \(sudokuItem.element?.number)")
            }
            .disposed(by: disposeBag)

        // 변경점 끝!!


        let informationViewModelOutput = bindingInformationViewModel(timerTrigger: input.timerTrigger)
        let boardViewModelOutput = bindingBoardViewModel(
            cellButtonTapped: input.cellButtonTapped,
            sudokuItem: updatedSudokuItem
        )

        return Output(
            informationOutput: informationViewModelOutput,
            boardOutput: boardViewModelOutput,
            sudoku: sudoku,
            loading: fetching.asDriver(onErrorJustReturn: false),
            alert: BehaviorSubject<AlertView.Alert>(value: .back)
        )
    }

    private func bindingInformationViewModel(timerTrigger: Driver<Void>) -> InformationViewModel.Output {
        let input = InformationViewModel.Input(
            sudoku: sudoku,
            timerTrigger: timerTrigger,
            mistakeTrigger: mistakeTrigger
        )

        return informationViewModel.transform(input: input)
    }

    private func bindingBoardViewModel(
        cellButtonTapped: Observable<IndexPath>,
        sudokuItem: Observable<SudokuItem>
    ) -> BoardViewModel.Output {
        let input = BoardViewModel.Input(
            sudoku: sudoku,
            sudokuItem: sudokuItem,
            cellButtonTapped: cellButtonTapped
        )

        return boardViewModel.transform(input: input)
    }
}
