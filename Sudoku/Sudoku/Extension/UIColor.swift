//
//  UIColor.swift
//  Sudoku
//
//  Created by 박재우 on 11/20/23.
//

import UIKit

extension UIColor {
    static var mainColor: UIColor = .mainBlue
    static var brightMainColor1: UIColor {
        mainColor.blend(with: .white.withAlphaComponent(0.3))
    }
    static var brightMainColor2: UIColor {
        mainColor.blend(with: .white.withAlphaComponent(0.5))
    }
    static var darkMainColor1: UIColor {
        mainColor.blend(with: .black.withAlphaComponent(0.3))
    }
    static var darkMainColor2: UIColor {
        mainColor.blend(with: .black.withAlphaComponent(0.5))
    }

    func blend(with color: UIColor) -> UIColor {
        var alpha1: CGFloat = 0
        var red1: CGFloat = 0
        var green1: CGFloat = 0
        var blue1: CGFloat = 0

        var alpha2: CGFloat = 0
        var red2: CGFloat = 0
        var green2: CGFloat = 0
        var blue2: CGFloat = 0

        self.getRed(&red1, green: &green1, blue: &blue1, alpha: &alpha1)
        color.getRed(&red2, green: &green2, blue: &blue2, alpha: &alpha2)

        let blendedRed = (red1 * (1 - alpha2)) + (red2 * alpha2)
        let blendedGreen = (green1 * (1 - alpha2)) + (green2 * alpha2)
        let blendedBlue = (blue1 * (1 - alpha2)) + (blue2 * alpha2)

        return UIColor(red: blendedRed, green: blendedGreen, blue: blendedBlue, alpha: 1)
    }
}
