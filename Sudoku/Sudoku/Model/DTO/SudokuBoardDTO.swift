//
//  SudokuBoardDTO.swift
//  Sudoku
//
//  Created by 박재우 on 11/22/23.
//

import Foundation

struct SudokuBoardDTO: Decodable {
    let data: [SudokuData]
    let results: Int
    let message: String

    enum CodingKeys: String, CodingKey {
        case data = "grids"
        case results
        case message
    }
}
