//
//  ViewController.swift
//  Sudoku
//
//  Created by 박재우 on 11/14/23.
//

import UIKit

class ViewController: UIViewController {
    private let newGameButton = GameButton(type: .new)
    private let continueGameButton = GameButton(type: .continue)

    override func viewDidLoad() {
        super.viewDidLoad()

        setUI()
        setLayout()
    }

    private func setUI() {
        view.backgroundColor = .systemBackground

        continueGameButton.setSubtitle(timer: TimeInterval())
    }

    private func setLayout() {
        view.addSubview(newGameButton)
        view.addSubview(continueGameButton)

        newGameButton.translatesAutoresizingMaskIntoConstraints = false
        continueGameButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            newGameButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.65),
            newGameButton.heightAnchor.constraint(equalToConstant: 60),
            newGameButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            newGameButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -150),

            continueGameButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.65),
            continueGameButton.heightAnchor.constraint(equalToConstant: 60),
            continueGameButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            continueGameButton.bottomAnchor.constraint(equalTo: newGameButton.topAnchor, constant: -30)
        ])
    }
}

