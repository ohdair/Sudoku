//
//  Timer.swift
//  Sudoku
//
//  Created by 박재우 on 11/23/23.
//

import Foundation

extension Timer {
    static func startRepeating(_ target: Any, selector: Selector) -> Timer {
        Timer.scheduledTimer(timeInterval: 1, target: target, selector: selector, userInfo: nil, repeats: true)
    }
}
