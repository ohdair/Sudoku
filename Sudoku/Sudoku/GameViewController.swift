//
//  GameViewController.swift
//  Sudoku
//
//  Created by 박재우 on 11/20/23.
//

import UIKit

class GameViewController: UIViewController {
    private lazy var backBarButtonItem = UIBarButtonItem.back(self, selector: #selector(tappedBackBarButton))
    private lazy var pauseBarButtonItem = UIBarButtonItem.pause(self, selector: #selector(tappedPauseBarButton))

    private var isTimerRun: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setUI()
    }

    private func setUI() {
        self.title = "Sudoku"
        let navigationBar = self.navigationController?.navigationBar
        navigationBar?.titleTextAttributes = [.font: UIFont.systemFont(ofSize: 22, weight: .bold),
                                              .foregroundColor: UIColor.darkMainColor2]
        self.navigationItem.leftBarButtonItem = backBarButtonItem
        self.navigationItem.rightBarButtonItem = pauseBarButtonItem
    }

    @objc private func tappedBackBarButton(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }

    @objc private func tappedPauseBarButton(_ sender: UIBarButtonItem) {
        isTimerRun.toggle()
        pauseBarButtonItem.image = isTimerRun ? UIImage(systemName: "pause.circle") : UIImage(systemName: "play.circle")
    }
}
