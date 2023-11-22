//
//  GameDifficulty.swift
//  Sudoku
//
//  Created by 박재우 on 11/22/23.
//

import Foundation

enum GameDifficulty: String, Decodable {
    case easy = "쉬움"
    case medium = "보통"
    case hard = "어려움"
}
