//
//  HomeViewController.swift
//  Sudoku
//
//  Created by 박재우 on 11/14/23.
//

import UIKit
import RxSwift
import RxCocoa

class HomeViewController: UIViewController {

    private let newGameButton = GameButton(title: "New")
    private let continueGameButton = GameButton(title: "Continue", reveralColor: true)

    private var savedGame: Sudoku?

    private let disposeBag = DisposeBag()

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
        bind()
    }

    private func setUI() {
        view.backgroundColor = .systemBackground
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

    private func bind() {
        newGameButton.rx.tap
            .asDriver()
            .drive { _ in
                let gameViewController = GameViewController()
                self.navigationController?.pushViewController(gameViewController, animated: true)
            }
            .disposed(by: disposeBag)

        continueGameButton.rx.tap
            .asDriver()
            .drive { _ in
                let gameViewModel = GameViewModel(sudoku: self.savedGame!)
                let gameViewController = GameViewController(viewModel: gameViewModel)

                self.navigationController?.pushViewController(gameViewController, animated: true)
            }
            .disposed(by: disposeBag)
    }

}
