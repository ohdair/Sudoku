//
//  AlertViewController.swift
//  Sudoku
//
//  Created by 박재우 on 12/20/23.
//

import UIKit
import RxCocoa
import RxSwift

final class AlertViewController: UIViewController {

    private let blurEffectView = UIVisualEffectView()
    private let alertView = AlertView()
    private let alertViewModel = AlertViewModel()
    private let disposedBag = DisposeBag()

    private var input: AlertViewModel.Input

    init(input: AlertViewModel.Input) {
        self.input = input
        super.init(nibName: nil, bundle: nil)

        bindAlertViewModel()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setUI()
        setLayout()
    }

    private func setUI() {
        blurEffectView.effect = UIBlurEffect(style: .systemUltraThinMaterial)
        blurEffectView.alpha = 0.955
        blurEffectView.frame = view.bounds
    }

    private func setLayout() {
        view.addSubview(blurEffectView)
        view.addSubview(alertView)

        alertView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            alertView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            alertView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            alertView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            alertView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20)
        ])
    }

    private func bindAlertViewModel() {
        let output = alertViewModel.transform(input: input)

        output.title
            .drive(alertView.titleLabel.rx.text)
            .disposed(by: disposedBag)

        output.titleFontSize
            .map{ UIFont.systemFont(ofSize: $0, weight: .bold) }
            .drive(alertView.titleLabel.rx.font)
            .disposed(by: disposedBag)

        output.continueButtonIsHidden
            .drive(alertView.continueButton.rx.isHidden)
            .disposed(by: disposedBag)

        output.restartButtonIsHidden
            .drive(alertView.restartButton.rx.isHidden)
            .disposed(by: disposedBag)

        output.newGameButtonIsHidden
            .drive(alertView.newGameButton.rx.isHidden)
            .disposed(by: disposedBag)

        output.quitGameButtonIsHidden
            .drive(alertView.quitGameButton.rx.isHidden)
            .disposed(by: disposedBag)
    }

    func alertButton(of type: AlertButton.Alert) -> AlertButton {
        switch type {
        case .new:
            alertView.newGameButton
        case .continue:
            alertView.continueButton
        case .restart:
            alertView.restartButton
        case .quit:
            alertView.quitGameButton
        }
    }

}
