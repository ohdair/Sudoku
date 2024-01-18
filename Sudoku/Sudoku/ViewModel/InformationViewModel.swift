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
        var difficulty: Observable<GameDifficulty>
        var mistake: Observable<Int>
        var mistakeTrigger: Observable<Void>
        var time: Observable<TimeInterval>
        var timerTrigger: Driver<Void>
    }

    struct Output {
        var difficulty: Driver<String>
        var mistake: Driver<Int>
        var time: Driver<TimeInterval>
    }

    // MARK: - property
    private let mistake = BehaviorRelay<Int>(value: 0)
    private let time = BehaviorRelay<TimeInterval>(value: 0)
    private let isOnTimer = BehaviorRelay<Bool>(value: false)
    private let disposeBag = DisposeBag()

    func transform(input: Input) -> Output {
        let difficulty = input.difficulty
            .map { difficulty in
                difficulty.discription
            }
            .asDriver(onErrorJustReturn: "")

        input.mistakeTrigger
            .subscribe { _ in
                self.updateMistake()
            }
            .disposed(by: disposeBag)

        input.time
            .subscribe { time in
                self.time.accept(time)
                self.timerToggle()
            }
            .disposed(by: disposeBag)

        input.timerTrigger
            .drive { _ in
                self.timerToggle()
            }
            .disposed(by: disposeBag)

        // MARK: - 타이머가 ON일 때, time 1씩 증가
        Driver<Int>
            .interval(.seconds(1))
            .filter { _ in self.isOnTimer.value }
            .drive { _ in
                self.updateTimer()
            }
            .disposed(by: disposeBag)

        return Output(
            difficulty: difficulty,
            mistake: mistake.asDriver(),
            time: time.asDriver()
        )
    }

    private func timerToggle() {
        let value = isOnTimer.value
        isOnTimer.accept(!value)
    }

    private func updateMistake() {
        let mistake = self.mistake.value
        let updatedMistake = mistake < 3 ? mistake + 1 : mistake
        self.mistake.accept(updatedMistake)
    }

    private func updateTimer() {
        let time = self.time.value
        let updatedTime = time + 1
        self.time.accept(updatedTime)
    }
}

