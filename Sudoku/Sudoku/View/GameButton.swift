//
//  GameButton.swift
//  Sudoku
//
//  Created by 박재우 on 11/14/23.
//

import UIKit

class GameButton: UIButton {
    private var configure: UIButton.Configuration = {
        var config = UIButton.Configuration.filled()
        config.titleAlignment = .center
        config.cornerStyle = .capsule
        config.background.strokeWidth = 1.0
        return config
    }()

    convenience init(title: String, reveralColor: Bool = false) {
        self.init()

        configuration = configure
        setTitle(title)
        setColor(reversal: reveralColor)
    }

    func setTitle(_ title: String) {
        var attributedString = AttributedString.init(title)
        attributedString.font = .systemFont(ofSize: 28, weight: .heavy)

        configuration?.attributedTitle = attributedString
    }

    func setSubtitle(time: TimeInterval) {
        let mutableAttributedString = NSMutableAttributedString(string: "")
        let textAttachment = NSTextAttachment(image: UIImage(systemName: "timer")!)
        mutableAttributedString.append(NSAttributedString(attachment: textAttachment))
        mutableAttributedString.append(NSAttributedString(string: " \(time.time)"))

        configuration?.attributedSubtitle = AttributedString(mutableAttributedString)
    }

    func setColor(reversal: Bool) {
        if reversal {
            configuration?.baseForegroundColor = .white
            configuration?.baseBackgroundColor = .mainColor
            configuration?.background.strokeColor = .clear
        } else {
            configuration?.baseForegroundColor = .mainColor
            configuration?.baseBackgroundColor = .systemBackground
            configuration?.background.strokeColor = .mainColor
        }
    }
}
