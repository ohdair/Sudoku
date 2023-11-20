//
//  UIBarButtonItem.swift
//  Sudoku
//
//  Created by 박재우 on 11/20/23.
//

import UIKit

extension UIBarButtonItem {
    static func back(_ target: AnyObject?, selector: Selector?) -> UIBarButtonItem {
        let barButtonItem = UIBarButtonItem()
        let image = UIImage(systemName: "chevron.backward")?.withRenderingMode(.alwaysTemplate)

        barButtonItem.tintColor = .darkMainColor2
        barButtonItem.target = target
        barButtonItem.action = selector
        barButtonItem.image = image

        return barButtonItem
    }

    static func pause(_ target: AnyObject?, selector: Selector?) -> UIBarButtonItem {
        let barButtonItem = UIBarButtonItem()
        let image = UIImage(systemName: "pause.circle")?.withRenderingMode(.alwaysTemplate)

        barButtonItem.tintColor = .darkMainColor2
        barButtonItem.target = target
        barButtonItem.action = selector
        barButtonItem.image = image

        return barButtonItem
    }
}
