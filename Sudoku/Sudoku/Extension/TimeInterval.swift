//
//  TimeInterval.swift
//  Sudoku
//
//  Created by 박재우 on 11/14/23.
//

import Foundation

extension TimeInterval {
    var time: String {
        return String(format: "%d:%02d", Int(self/60), Int(ceil(truncatingRemainder(dividingBy: 60))))
    }
}
