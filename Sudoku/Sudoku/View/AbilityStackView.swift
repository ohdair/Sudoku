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

            if ability == .memo {
                abilityButton.addTarget(self, action: #selector(tappedMemoButton), for: .touchDown)
            }
        }

        distribution = .equalCentering
    }

    @objc private func tappedMemoButton(_ sender: AbilityButton) {
        sender.toggleMemo()
    }
}
