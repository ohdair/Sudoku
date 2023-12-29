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
        var backButtonTapped: Driver<Void>
        var pauseButtonTapped: Driver<Void>
        var mistakeTrigger: Driver<Void>
        var errorTrigger: Driver<Void>
    }

    struct Output {
        var title: Driver<String>
        var titleFontSize: Driver<CGFloat>
        var continueButtonIsHidden: Driver<Bool>
        var restartButtonIsHidden: Driver<Bool>
        var newGameButtonIsHidden: Driver<Bool>
        var quitGameButtonIsHidden: Driver<Bool>
    }

    private let alertSubject = PublishSubject<AlertView.Alert>()
    private let disposedBag = DisposeBag()

    func transform(input: Input) -> Output {
        let alert = conformAlert(input: input)

        let title = alert
            .map { $0.title }

        let fontSize = alert
            .map { $0.titleFontSize }

        let continueButtonIsHidden = alert
            .map { $0 == .overMistake || $0 == .error }

        let restartButtonIsHidden = alert
            .map { $0 != .overMistake }

        let newGameButtonIsHidden = alert
            .map { $0 == .back || $0 == .error }

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

    func conformAlert(input: Input) -> Driver<AlertView.Alert> {
        let backButtonAlert = input.backButtonTapped
            .map { AlertView.Alert.back }

        let pauseButtonAlert = input.pauseButtonTapped
            .map { AlertView.Alert.pause }

        let mistakeAlert = input.mistakeTrigger
            .map { AlertView.Alert.overMistake }

        let errorAlert = input.errorTrigger
            .map { AlertView.Alert.error }

        return Driver.merge(backButtonAlert, pauseButtonAlert, mistakeAlert, errorAlert)
            .do { alert in
                self.alertSubject.onNext(alert)
            }
    }

}
