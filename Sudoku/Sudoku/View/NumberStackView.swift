//
//  NumberStackView.swift
//  Sudoku
//
//  Created by 박재우 on 12/5/23.
//

import UIKit

class NumberStackView: UIStackView {

    private(set) var numberButtons = [NumberButton]()

    override init(frame: CGRect) {
        super.init(frame: .zero)

        setUI()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUI() {
        stride(from: 1, through: 9, by: 1).forEach { number in
            let button = NumberButton(number: number)
            numberButtons.append(button)
            addArrangedSubview(button)
        }

        distribution = .equalCentering
    }

    func addTargetNumberButtons(_ target: AnyObject?, selector: Selector) {
        subviews.forEach { view in
            (view as! NumberButton).addTarget(target, action: selector, for: .touchDown)
        }
    }
}
