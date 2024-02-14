//
//  InformationView.swift
//  Sudoku
//
//  Created by 박재우 on 11/22/23.
//

import UIKit

class InformationView: UIView {
    private let titleLabel = {
        let imageViewLabel = UILabel()
        imageViewLabel.font = .systemFont(ofSize: 18, weight: .bold)
        imageViewLabel.textColor = .brightMainColor1
        imageViewLabel.textAlignment = .center
        return imageViewLabel
    }()

    let contentLabel = {
        let imageViewLabel = UILabel()
        imageViewLabel.font = .systemFont(ofSize: 13, weight: .bold)
        imageViewLabel.textColor = .brightMainColor1
        imageViewLabel.textAlignment = .center
        return imageViewLabel
    }()

    convenience init(type: Information) {
        self.init()

        titleLabel.text = type.title
        setLayout()
    }

    private func setLayout() {
        addSubview(titleLabel)
        addSubview(contentLabel)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: contentLabel.topAnchor, constant: -8),

            contentLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            contentLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            contentLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
    }
}

extension InformationView {
    enum Information {
        case difficulty
        case mistake
        case timer

        fileprivate var title: String {
            switch self {
            case .difficulty:
                return "난이도"
            case .mistake:
                return "실수"
            case .timer:
                return "시간"
            }
        }
    }
}
