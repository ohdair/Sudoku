//
//  AbilityButton.swift
//  Sudoku
//
//  Created by 박재우 on 11/21/23.
//

import UIKit

class AbilityButton: UIButton {
    private let abilityImageLabel = {
        let imageViewLabel = UILabel()
        imageViewLabel.font = .systemFont(ofSize: 30, weight: .bold)
        imageViewLabel.textColor = .brightMainColor2
        imageViewLabel.textAlignment = .center
        return imageViewLabel
    }()

    private let abilityLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .brightMainColor2
        label.textAlignment = .center
        return label
    }()

    private let memoToggleLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.text = "off"
        label.textColor = .white
        label.textAlignment = .center
        label.backgroundColor = .brightMainColor2
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        label.layer.borderWidth = 2
        label.layer.borderColor = UIColor.systemBackground.cgColor
        return label
    }()

    let type: Ability
    private(set) var isOnMemo = false

    init(of type: Ability) {
        self.type = type

        super.init(frame: .zero)

        abilityImageLabel.attributedText = mutableAttributedString(in: type.image)
        abilityLabel.text = type.description

        setLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setLayout() {
        addSubview(abilityImageLabel)
        addSubview(abilityLabel)

        abilityImageLabel.translatesAutoresizingMaskIntoConstraints = false
        abilityLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            abilityImageLabel.topAnchor.constraint(equalTo: self.topAnchor),
            abilityImageLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            abilityImageLabel.bottomAnchor.constraint(equalTo: abilityLabel.topAnchor, constant: -8),
            abilityImageLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),

            abilityLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            abilityLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            abilityLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])

        if type == .memo {
            addSubview(memoToggleLabel)
            memoToggleLabel.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                memoToggleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
                memoToggleLabel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.7),
                memoToggleLabel.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.3),
                memoToggleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 5),
            ])
        }
    }

    private func mutableAttributedString(in image: UIImage) -> NSMutableAttributedString {
        let mutableAttributedString = NSMutableAttributedString()
        let imageAttachment = NSTextAttachment(image: image)
        let imageToString = NSAttributedString(attachment: imageAttachment)
        mutableAttributedString.append(imageToString)
        return mutableAttributedString
    }

    func toggleMemo() {
        isOnMemo.toggle()
        if isOnMemo {
            memoToggleLabel.text = "on"
            memoToggleLabel.backgroundColor = .mainColor
        } else {
            memoToggleLabel.text = "off"
            memoToggleLabel.backgroundColor = .brightMainColor2
        }
    }
}

extension AbilityButton {
    enum Ability: CaseIterable {
        case undo
        case erase
        case memo

        var description: String {
            switch self {
            case .undo:
                return "실행 취소"
            case .erase:
                return "지우기"
            case .memo:
                return "메모"
            }
        }

        var image: UIImage {
            switch self {
            case .undo:
                return UIImage(systemName: "arrow.uturn.backward")!
            case .erase:
                return UIImage(systemName: "eraser")!
            case .memo:
                return UIImage(systemName: "pencil.line")!
            }
        }
    }
}
