//
//  GameDifficulty.swift
//  Sudoku
//
//  Created by 박재우 on 11/22/23.
//

import Foundation

enum GameDifficulty: String, Codable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"

    var discription: String {
        switch self {
        case .easy:
            return "쉬움"
        case .medium:
            return "보통"
        case .hard:
            return "어려움"
        }
    }
}
