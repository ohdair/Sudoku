//
//  InformationViewModel.swift
//  Sudoku
//
//  Created by 박재우 on 12/14/23.
//

import Foundation
import RxSwift
import RxCocoa

final class InformationViewModel: ViewModelType {

    struct Input {
        var sudoku: Observable<Sudoku?>
        var timerTrigger: Driver<Void>
        var mistakeTrigger: Observable<Void>
    }

    struct Output {
        var difficulty: Driver<String>
        var mistake: Driver<Int>
        var time: Driver<Int>
    }

    // MARK: - property
    private let difficulty = BehaviorRelay<String>(value: "")
    private let mistake = BehaviorRelay<Int>(value: 0)
    private let time = BehaviorRelay<Int>(value: 0)
    private let isOnTimer = BehaviorRelay<Bool>(value: true)
    private let disposeBag = DisposeBag()

    private func toggle() {
        let value = isOnTimer.value
        isOnTimer.accept(!value)
    }

    func transform(input: Input) -> Output {
        let startedTime = 0

        input.sudoku
            .compactMap { $0 }
            .subscribe { sudoku in
                let difficulty = sudoku.data.difficulty.discription
                self.difficulty.accept(difficulty)
                self.mistake.accept(sudoku.mistake)
                startedTime = sudoku.time
            }
            .disposed(by: disposeBag)

        input.timerTrigger
            .drive { _ in
                self.toggle()
            }
            .disposed(by: disposeBag)

        input.mistakeTrigger
            .subscribe { _ in
                let value = self.mistake.value
                let mistake = value < 3 ? value + 1 : value
                self.mistake.accept(mistake)
            }
            .disposed(by: disposeBag)

        let time = Observable<Int>
            .interval(.seconds(1), scheduler: MainScheduler.instance)
            .withLatestFrom(isOnTimer)
            .filter { $0 }
            .scan(startedTime) { time, _ in
                time + 1
            }
            .startWith(startedTime)
            .asDriver(onErrorJustReturn: startedTime)

        return Output(
            difficulty: difficulty.asDriver(),
            mistake: mistake.asDriver(),
            time: time
        )
    }
}

