//
//  AlertButton.swift
//  Sudoku
//
//  Created by 박재우 on 12/24/23.
//

import UIKit

final class AlertButton: GameButton {

    convenience init(type: Alert) {
        switch type {
        case .new:
            self.init(title: "새 게임", reveralColor: true)
            configuration?.baseBackgroundColor = .red.withAlphaComponent(0.8)
        case .continue:
            self.init(title: "게임 재개", reveralColor: true)
        case .restart:
            self.init(title: "다시 시작", reveralColor: true)
        case .quit:
            self.init(title: "나가기", reveralColor: true)
            configuration?.baseBackgroundColor = .red.withAlphaComponent(0.8)
        }
    }

}

extension AlertButton {

    enum Alert {
        case new
        case `continue`
        case restart
        case quit
    }

}
