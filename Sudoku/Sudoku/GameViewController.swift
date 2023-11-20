//
//  GameViewController.swift
//  Sudoku
//
//  Created by 박재우 on 11/20/23.
//

import UIKit

class GameViewController: UIViewController {
    private lazy var leftBarButton = {
        let barButtonItem = UIBarButtonItem()
        let image = UIImage(systemName: "chevron.backward")?.withTintColor(.darkMainColor2, renderingMode: .alwaysOriginal)

        barButtonItem.target = self
        barButtonItem.action = #selector(self.tappedleftBarButton)
        barButtonItem.image = image

        return barButtonItem
    }()

    private lazy var rightBarButton = {
        let barButtonItem = UIBarButtonItem()
        let image = UIImage(systemName: "pause.circle")?.withTintColor(.darkMainColor2, renderingMode: .alwaysOriginal)
        barButtonItem.target = self
        barButtonItem.action = #selector(self.tappedRightBarButton)
        barButtonItem.image = image

        return barButtonItem
    }()

    private var isTimerRun: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setUI()
    }

    private func setUI() {
        self.title = "Sudoku"
        self.navigationController?.navigationBar.titleTextAttributes = [.font: UIFont.systemFont(ofSize: 22, weight: .bold),
                                                                        .foregroundColor: UIColor.darkMainColor2]
        self.navigationItem.leftBarButtonItem = leftBarButton
        self.navigationItem.rightBarButtonItem = rightBarButton
    }

    @objc private func tappedleftBarButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    @objc private func tappedRightBarButton(_ sender: UIButton) {
        isTimerRun.toggle()
        rightBarButton.image = isTimerRun ?
        UIImage(systemName: "pause.circle")?.withTintColor(.darkMainColor2, renderingMode: .alwaysOriginal) :
        UIImage(systemName: "play.circle")?.withTintColor(.darkMainColor2, renderingMode: .alwaysOriginal)
    }
}
