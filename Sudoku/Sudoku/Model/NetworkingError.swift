//
//  NetworkingError.swift
//  Sudoku
//
//  Created by 박재우 on 11/22/23.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case transportError
    case serverError
    case missingData
    case decodingError
}
