//
//  SudokuDataDTO.swift
//  Sudoku
//
//  Created by 박재우 on 11/22/23.
//

import Foundation

struct SudokuDataDTO: Decodable {
    let newboard: SudokuBoardDTO

    func fetch() -> SudokuData? {
        return newboard.data.first
    }
}
