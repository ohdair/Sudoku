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
        var toggleTimer: Driver<Void>
        var mistakeTrigger: Driver<Void>
    }

    struct Output {
        var difficulty: Driver<String>
        var mistake: Driver<Int>
        var isOnTimer: Driver<Bool>
        var time: Driver<Int>
    }

    // MARK: - property

    private let difficulty: GameDifficulty
    private var mistake: Int
    private var time: Int

    init(
        difficulty: GameDifficulty,
        mistake: Int,
        time: Int
    ) {
        self.difficulty = difficulty
        self.mistake = mistake
        self.time = time
    }

    func transform(input: Input) -> Output {
        let difficulty = Driver<String>
            .from(optional: self.difficulty.discription)
            .startWith(self.difficulty.discription)

        let mistake = input.mistakeTrigger
            .scan(self.mistake) { count, _ in
                return count < 3 ? count + 1 : count
            }
            .startWith(self.mistake)

        let isOnTimer: Driver<Bool> = input.toggleTimer
            .scan(true) { (previousValue, _) in
                return !previousValue
            }
            .startWith(true)

        let time = Driver<Int>
            .interval(.seconds(1))
            .withLatestFrom(isOnTimer) { $1 ? 1 : 0 }
            .filter { $0 > 0 }
            .scan(self.time) { $0 + $1 }
            .startWith(self.time)

        return Output(
            difficulty: difficulty,
            mistake: mistake,
            isOnTimer: isOnTimer,
            time: time
        )
    }
}

