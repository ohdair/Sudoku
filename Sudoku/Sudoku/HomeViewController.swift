//
//  HomeViewController.swift
//  Sudoku
//
//  Created by 박재우 on 11/14/23.
//

import UIKit

class HomeViewController: UIViewController {
    private let newGameButton = GameButton(type: .new)
    private let continueGameButton = GameButton(type: .continue)
    private var savedGame: Sudoku?

    override func viewWillAppear(_ animated: Bool) {
        if let savedSudoku = UserDefaults.standard.object(forKey: "Sudoku") as? Data,
           let loadedSudoku = try? JSONDecoder().decode(Sudoku.self, from: savedSudoku) {
            savedGame = loadedSudoku
            continueGameButton.setSubtitle(time: loadedSudoku.time)
        }
        continueGameButton.isHidden = savedGame == nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setUI()
        setLayout()
    }

    private func setUI() {
        view.backgroundColor = .systemBackground

        continueGameButton.addTarget(self, action: #selector(tappedContinueButton), for: .touchDown)
        newGameButton.addTarget(self, action: #selector(tappedNewGameButton), for: .touchDown)
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

    @objc func tappedNewGameButton(_ sender: UIButton) {
        let gameViewController = GameViewController()
        self.navigationController?.pushViewController(gameViewController, animated: true)
    }

    @objc func tappedContinueButton(_ sender: UIButton) {
        let gameViewController = GameViewController()
        if let savedGame {
            gameViewController.sudoku = savedGame
        }
        self.navigationController?.pushViewController(gameViewController, animated: true)
    }
}

