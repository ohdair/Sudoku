//
//  SudokuData.swift
//  Sudoku
//
//  Created by 박재우 on 11/22/23.
//

import Foundation

struct SudokuData: Decodable {
    let problem: [[Int]]
    let solution: [[Int]]
    let difficulty: GameDifficulty

    enum CodingKeys: String, CodingKey {
        case problem = "value"
        case solution
        case difficulty
    }
}
