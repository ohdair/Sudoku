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
        var cellButtonTapped: Driver<IndexPath>
        var abilityButtonTapped: Driver<AbilityButton.Ability>
        var numberButtonTapped: Driver<Int>
        var saveGameTrigger: Observable<Void>
    }

    struct Output {
        var informationOutput: InformationViewModel.Output
        var boardOutput: BoardViewModel.Output
        var sudoku: Observable<Sudoku>
        var loading: Driver<Bool>
        var alert: Observable<AlertView.Alert>
        var board: Driver<[[SudokuItem]]>
        var isOnMemo: Driver<Bool>
    }

    private let sudoku = PublishSubject<Sudoku>()
    private let fetching = PublishSubject<Bool>()
    private let disposeBag = DisposeBag()
    private let board = BehaviorRelay<[[SudokuItem]]>(value: [])

    private var savedSudoku: Sudoku?

    // ViewModel
    private let informationViewModel = InformationViewModel()
    private let boardViewModel = BoardViewModel()
    private let abilityViewModel = AbilityViewModel()

    // State
    private let isOnMemo = BehaviorRelay<Bool>(value: false)

    // Action
    private let eraseTrigger = PublishSubject<Void>()
    private let mistakeTrigger = PublishSubject<Void>()
    private let reformTrigger = PublishRelay<Void>()

    init(sudoku: Sudoku) {
        self.savedSudoku = sudoku
        self.sudoku.onNext(sudoku)
        self.board.accept(sudoku.board)
    }

    init() { }

    private func fetchSudoku() {
        LoadingIndicator.showLoading()

        Networking.request()
            .subscribe { sudokuData in
                self.reformTrigger.accept(())
                let sudoku = Sudoku(data: sudokuData)
                self.sudoku.onNext(sudoku)
                self.board.accept(sudoku.board)
                LoadingIndicator.hideLoading()
            } onError: { error in
                LoadingIndicator.hideLoading()
                self.sudoku.onCompleted()
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
            .asObservable()
            .withLatestFrom(sudoku)
            .subscribe(onNext: { sudoku in
                self.reformTrigger.accept(())
                let newSudoku = Sudoku(data: sudoku.data)
                self.sudoku.onNext(newSudoku)
                self.board.accept(newSudoku.board)
            })
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

        let informationViewModelOutput = bindingInformationViewModel(timerTrigger: input.timerTrigger)
        let boardViewModelOutput = bindingBoardViewModel(
            cellButtonTapped: input.cellButtonTapped,
            numberButtonTapped: input.numberButtonTapped,
            reformTrigger: Driver.merge(input.reGameTapped, input.newGameTapped)
        )

        bindingAbilityViewModel(ability: input.abilityButtonTapped)

        boardViewModelOutput.board
            .drive(board)
            .disposed(by: disposeBag)

        boardViewModelOutput.mistakeTrigger
            .drive(mistakeTrigger)
            .disposed(by: disposeBag)

        let combinedObservable = Observable.combineLatest(
            sudoku.asObservable(),
            informationViewModelOutput.mistake.asObservable(),
            informationViewModelOutput.time.asObservable(),
            board.asObservable()
        )

        input.saveGameTrigger
            .withLatestFrom(combinedObservable)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { sudoku, mistake, time, board in
                var sudoku = sudoku
                sudoku.board = board
                sudoku.mistake = mistake
                sudoku.time = time
                
                if let encoded = try? JSONEncoder().encode(sudoku) {
                    UserDefaults.standard.setValue(encoded, forKey: "Sudoku")
                }
            })
            .disposed(by: disposeBag)

        return Output(
            informationOutput: informationViewModelOutput,
            boardOutput: boardViewModelOutput,
            sudoku: sudoku,
            loading: fetching.asDriver(onErrorJustReturn: false),
            alert: BehaviorSubject<AlertView.Alert>(value: .back),
            board: board.asDriver(),
            isOnMemo: isOnMemo.asDriver()
        )
    }

    private func bindingInformationViewModel(timerTrigger: Driver<Void>) -> InformationViewModel.Output {
        let observableDifficulty = sudoku.map { $0.data.difficulty }
        let observableMistake = sudoku.map { $0.mistake }
        let observableTime = sudoku.map { $0.time }
        let input = InformationViewModel.Input(
            difficulty: observableDifficulty,
            mistake: observableMistake,
            mistakeTrigger: mistakeTrigger,
            time: observableTime,
            timerTrigger: timerTrigger
        )

        return informationViewModel.transform(input: input)
    }

    private func bindingBoardViewModel(
        cellButtonTapped: Driver<IndexPath>,
        numberButtonTapped: Driver<Int>,
        reformTrigger: Driver<Void>
    ) -> BoardViewModel.Output {
        let observableData = sudoku.map { $0.data }
        let input = BoardViewModel.Input(
            data: observableData,
            board: board.asObservable(),
            isOnMemo: isOnMemo.asDriver(),
            cellButtonTapped: cellButtonTapped,
            numberButtonTapped: numberButtonTapped,
            eraseTrigger: eraseTrigger.asDriver(onErrorJustReturn: ()),
            reformTrigger: reformTrigger
        )

        return boardViewModel.transform(input: input)
    }

    private func bindingAbilityViewModel(ability: Driver<AbilityButton.Ability>) {
        let input = AbilityViewModel.Input(
            board: board.asObservable(),
            ability: ability,
            reformTrigger: reformTrigger.asObservable()
        )

        let output = abilityViewModel.transform(input: input)

        output.board
            .drive(board)
            .disposed(by: disposeBag)

        output.eraseTrigger
            .drive(eraseTrigger)
            .disposed(by: disposeBag)

        output.isOnMemo
            .drive(isOnMemo)
            .disposed(by: disposeBag)
    }

}
