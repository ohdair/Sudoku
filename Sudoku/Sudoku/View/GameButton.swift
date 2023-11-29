//
//  GameButton.swift
//  Sudoku
//
//  Created by 박재우 on 11/14/23.
//

import UIKit

class GameButton: UIButton {
    convenience init(type: ButtonType) {
        self.init()

        var config = UIButton.Configuration.filled()

        var titleAttribute = AttributedString.init(type.title)
        titleAttribute.font = .systemFont(ofSize: 28, weight: .heavy)

        config.attributedTitle = titleAttribute
        config.baseForegroundColor = type.foregroundColor
        config.baseBackgroundColor = type.backgroundColor
        config.titleAlignment = .center
        config.cornerStyle = .capsule
        config.background.strokeColor = type.borderColor
        config.background.strokeWidth = 1.0

        configuration = config
    }

    func setSubtitle(time: Int) {
        let mutableAttributedString = NSMutableAttributedString(string: "")
        let textAttachment = NSTextAttachment(image: UIImage(systemName: "timer")!)
        mutableAttributedString.append(NSAttributedString(attachment: textAttachment))
        let timeInterval = TimeInterval(truncating: time as NSNumber)
        mutableAttributedString.append(NSAttributedString(string: " \(timeInterval.time)"))

        configuration?.attributedSubtitle = AttributedString(mutableAttributedString)
    }
}

extension GameButton {
    enum ButtonType {
        case new
        case `continue`

        var backgroundColor: UIColor {
            switch self {
            case .new:
                return .systemBackground
            case .continue:
                return .mainBlue
            }
        }

        var title: String {
            switch self {
            case .new:
                return "New"
            case .continue:
                return "Continue"
            }
        }

        var foregroundColor: UIColor {
            switch self {
            case .new:
                return .mainBlue
            case .continue:
                return .white
            }
        }

        var borderColor: UIColor {
            switch self {
            case .new:
                return .mainBlue
            case .continue:
                return .clear
            }
        }
    }
}
