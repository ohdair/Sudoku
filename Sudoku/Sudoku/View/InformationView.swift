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

    private let type: Information

    init(type: Information) {
        self.type = type

        super.init(frame: .zero)

        setUI()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUI() {
        titleLabel.text = type.title
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

    func updateContent(_ content: Any) {
        switch type {
        case .difficulty:
            contentLabel.text = "\(content)"
        case .mistake:
            contentLabel.text = "\(content) / 3"
        case .timer:
            contentLabel.text = updateTime(content as! Int)
        }
    }

    private func updateTime(_ time: Int) -> String {
        let minutes = time / 60
        let seconds = time % 60

        return String(format: "%02d:%02d", minutes, seconds)
    }

}

extension InformationView {
    enum Information: CaseIterable {
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
