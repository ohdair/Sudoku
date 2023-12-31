//
//  AbilityStackView.swift
//  Sudoku
//
//  Created by 박재우 on 12/5/23.
//

import UIKit

class AbilityStackView: UIStackView {
    override init(frame: CGRect) {
        super.init(frame: .zero)

        setUI()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUI() {
        AbilityButton.Ability.allCases.forEach { ability in
            let abilityButton = AbilityButton(of: ability)
            addArrangedSubview(abilityButton)
        }

        distribution = .equalCentering
    }

    func addTarget(_ target: AnyObject?, selector: Selector, ability: AbilityButton.Ability) {
        subviews.filter { view in
            (view as! AbilityButton).type == ability
        }.forEach { view in
            (view as! AbilityButton).addTarget(target, action: selector, for: .touchDown)
        }
    }
}
