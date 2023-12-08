//
//  Array.swift
//  Sudoku
//
//  Created by 박재우 on 12/6/23.
//

import Foundation

extension Array where Element: Collection {
    func compactMapMatrix<T>(_ transform: (_ row: Int, _ column: Int, Element.Element) -> T?) -> [[T]] {
        return self.enumerated().compactMap { row, elementArray in
            return elementArray.enumerated().compactMap { column, element in
                return transform(row, column, element)
            }
        }
    }
}
