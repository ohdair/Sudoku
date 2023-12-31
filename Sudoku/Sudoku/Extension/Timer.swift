//
//  Timer.swift
//  Sudoku
//
//  Created by 박재우 on 11/23/23.
//

import Foundation

extension Timer {
    static func startRepeating(_ target: Any, selector: Selector) -> Timer {
        let timer = Timer.scheduledTimer(
            timeInterval: 1,
            target: target,
            selector: selector,
            userInfo: nil,
            repeats: true
        )
        timer.tolerance = 0.1

        return timer
    }
}
