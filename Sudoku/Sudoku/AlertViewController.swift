//
//  AlertViewController.swift
//  Sudoku
//
//  Created by 박재우 on 12/20/23.
//

import UIKit

final class AlertViewController: UIViewController {

    private let blurEffectView = UIVisualEffectView()
    private let alertView = AlertView()

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
}
