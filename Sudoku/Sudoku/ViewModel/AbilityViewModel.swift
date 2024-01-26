//
//  AbilityViewModel.swift
//  Sudoku
//
//  Created by 박재우 on 1/25/24.
//

import Foundation
import RxSwift
import RxCocoa

/// 각 기능별 동작을 처리하며, 변경된 board를 history에 저장하는 역할
///
/// undo : 이전 history로 업데이트하여 output에 변경된 board를 emit
///
/// erase : 입력받은 이벤트를 Trigger로 변경, 커서에 따른 동작으로 BoardViewModel에서 처리
///
/// memo : 입력받은 이벤트를 Boolean으로 변경, memo의 on/off를 나타냄
final class AbilityViewModel: ViewModelType {

    typealias Board = [[SudokuItem]]

    struct Input {
        var board: Observable<Board>
        var ability: Driver<AbilityButton.Ability>
    }

    struct Output {
        var board: Driver<Board>
        var eraseTrigger: Driver<Void>
        var isOnMemo: Driver<Bool>
    }

    private var history = [Board]()
    private let board = PublishRelay<Board>()
    private let isOnMemo = BehaviorRelay<Bool>(value: false)
    private let disposeBag = DisposeBag()

    func transform(input: Input) -> Output {
        // MARK: - 외부에서 업데이트 된 Board를 history에 push
        input.board
            .subscribe { self.pushBoard($0) }
            .disposed(by: disposeBag)

        let undoBoard = input.ability
            .filter { $0 == .undo }
            .map { _ in self.undoBoard() }

        let eraseTrigger = input.ability
            .filter { $0 == .erase }
            .map { _ in }

        input.ability
            .filter { $0 == .memo }
            .map { _ in !self.isOnMemo.value }
            .drive(isOnMemo)
            .disposed(by: disposeBag)

        return Output(
            board: undoBoard,
            eraseTrigger: eraseTrigger,
            isOnMemo: isOnMemo.asDriver()
        )
    }

    private func pushBoard(_ board: Board) {
        guard let top = history.last,
              board == top else {
            return
        }

        history.append(board)
    }

    private func undoBoard() -> Board {
        guard history.count > 1 else {
            return history.last!
        }

        history.removeLast()
        return history.last!
    }
}
