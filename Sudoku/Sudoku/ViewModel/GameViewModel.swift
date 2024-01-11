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
    }

    struct Output {
        var informationOutput: InformationViewModel.Output

        var sudoku: Observable<Sudoku>
        var loading: Driver<Bool>
        var alert: Observable<AlertView.Alert>
    }

    private let sudoku = PublishSubject<Sudoku>()
    private let mistakeTrigger = PublishSubject<Void>()
    private let fetching = PublishSubject<Bool>()
    private let disposeBag = DisposeBag()
    private let informationViewModel = InformationViewModel()

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
            .compactMap { $0 }
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

        let informationViewModelOutput = bindingInformationViewModel(timerTrigger: input.timerTrigger)

        return Output(
            informationOutput: informationViewModelOutput,
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
}
