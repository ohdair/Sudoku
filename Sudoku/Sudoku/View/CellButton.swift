//
//  CellButton.swift
//  Sudoku
//
//  Created by 박재우 on 11/26/23.
//

import UIKit

class CellButton: UIButton {
    let indexPath: IndexPath
    private let numberLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 33, weight: .semibold)
        return label
    }()
    private var memoLabels = [UILabel]()
    private(set) var number: Int? {
        didSet {
            numberLabel.text = convert(of: number)
        }
    }

    init(item: Int, section: Int) {
        indexPath = IndexPath(item: item, section: section)

        super.init(frame: .zero)

        setUI()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUI() {
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.systemGray5.cgColor

        for index in stride(from: 0, to: 9, by: 1) {
            let label = UILabel()
            label.text = "\(index + 1)"
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 12, weight: .light)
            label.isHidden = true

            memoLabels.append(label)
        }
    }

    private func setupLayout() {
        addSubview(numberLabel)

        numberLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            numberLabel.topAnchor.constraint(equalTo: topAnchor),
            numberLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            numberLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            numberLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        for (index, memoLabel) in memoLabels.enumerated() {
            addSubview(memoLabel)

            memoLabel.translatesAutoresizingMaskIntoConstraints = false

            let topAnchor = index / 3 == 0 ? topAnchor : memoLabels[index - 3].bottomAnchor
            let leadingAnchor = index % 3 == 0 ? leadingAnchor : memoLabels[index % 3 - 1].trailingAnchor

            NSLayoutConstraint.activate([
                memoLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1 / 3),
                memoLabel.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1 / 3),
                memoLabel.topAnchor.constraint(equalTo: topAnchor),
                memoLabel.leadingAnchor.constraint(equalTo: leadingAnchor)
            ])
        }
    }

    private func convert(of number: Int?) -> String {
        guard let number else {
            return ""
        }

        return number.description
    }
}

extension CellButton {
    func number(to number: Int) {
        resetMemo()

        self.number = number
    }

    func reset() {
        number = nil

        resetMemo()
    }

    func resetMemo() {
        memoLabels.forEach {
            $0.isHidden = true
        }
    }

    func memo(to number: Int) {
        if self.number != nil {
            self.number = nil
        }

        memoLabels[number - 1].isHidden.toggle()
    }

    func paintedBackground(according state: State) {
        switch state {
        case .selected, .associatedNumber:
            backgroundColor = .brightMainColor1
        case .associatedCursor:
            backgroundColor = .brightMainColor2
        case .mistake:
            backgroundColor = .systemRed.withAlphaComponent(0.3)
        case .normal:
            backgroundColor = .clear
        }
    }

    func paintedTextColor(according state: State) {
        switch state {
        case .mistake:
            numberLabel.textColor = .red
        default:
            numberLabel.textColor = .darkMainColor1
        }
    }
}

extension CellButton {
    enum State {
        case associatedNumber
        case associatedCursor
        case selected
        case mistake
        case normal
    }
}
