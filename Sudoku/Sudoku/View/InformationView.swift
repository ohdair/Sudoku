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

    private let contentLabel = {
        let imageViewLabel = UILabel()
        imageViewLabel.font = .systemFont(ofSize: 13, weight: .bold)
        imageViewLabel.textColor = .brightMainColor1
        imageViewLabel.textAlignment = .center
        return imageViewLabel
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

    func updateContent(by type: Information) {
        titleLabel.text = type.title
        switch type {
        case .difficulty(let content):
            contentLabel.text = content
        case .mistake(let content):
            contentLabel.text = "\(content) / 3"
        case .timer(let content):
            contentLabel.text = updateTime(content)
        }
    }

    private func updateTime(_ time: Int) -> String {
        let minutes = time / 60
        let seconds = time % 60

        return String(format: "%02d:%02d", minutes, seconds)
    }
}

extension InformationView {
    enum Information {
        case difficulty(content: String)
        case mistake(content: Int)
        case timer(content: Int)

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
