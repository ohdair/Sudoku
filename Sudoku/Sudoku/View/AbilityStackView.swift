//
//  AbilityStackView.swift
//  Sudoku
//
//  Created by 박재우 on 12/5/23.
//

import UIKit

class AbilityStackView: UIStackView {

    private let undoButton = AbilityButton(of: .undo)
    private let eraseButton = AbilityButton(of: .erase)
    private let memoButton = AbilityButton(of: .memo)

    override init(frame: CGRect) {
        super.init(frame: .zero)

        setUI()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUI() {
        addArrangedSubview(undoButton)
        addArrangedSubview(eraseButton)
        addArrangedSubview(memoButton)

        distribution = .equalCentering
    }

    func addTarget(_ target: AnyObject?, selector: Selector, ability: AbilityButton.Ability) {
        subviews.filter { view in
            (view as! AbilityButton).type == ability
        }.forEach { view in
            (view as! AbilityButton).addTarget(target, action: selector, for: .touchDown)
        }
    }

    func button(of ability: AbilityButton.Ability) -> AbilityButton {
        switch ability {
        case .undo:
            return undoButton
        case .erase:
            return eraseButton
        case .memo:
            return memoButton
        }
    }
}
