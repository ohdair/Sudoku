//
//  AlertViewModel.swift
//  Sudoku
//
//  Created by 박재우 on 12/27/23.
//

import Foundation
import RxCocoa
import RxSwift

final class AlertViewModel: ViewModelType {

    struct Input {
        var alertTrigger: Observable<AlertView.Alert>
    }

    struct Output {
        var title: Driver<String>
        var titleFontSize: Driver<CGFloat>
        var continueButtonIsHidden: Driver<Bool>
        var restartButtonIsHidden: Driver<Bool>
        var newGameButtonIsHidden: Driver<Bool>
        var quitGameButtonIsHidden: Driver<Bool>
    }

    func transform(input: Input) -> Output {
        let alert = input.alertTrigger
            .asDriver(onErrorJustReturn: .back)

        let title = alert
            .map { $0.title }

        let fontSize = alert
            .map { $0.titleFontSize }

        let continueButtonIsHidden = alert
            .map { $0 == .overMistake || $0 == .error || $0 == .success }

        let restartButtonIsHidden = alert
            .map { $0 != .overMistake }

        let newGameButtonIsHidden = alert
            .map { $0 == .back || $0 == .error || $0 == .success }

        let quitGameButtonIsHidden = alert
            .map { $0 == .pause || $0 == .overMistake }

        return Output(
            title: title,
            titleFontSize: fontSize,
            continueButtonIsHidden: continueButtonIsHidden,
            restartButtonIsHidden: restartButtonIsHidden,
            newGameButtonIsHidden: newGameButtonIsHidden,
            quitGameButtonIsHidden: quitGameButtonIsHidden
        )
    }

}
