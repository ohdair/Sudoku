//
//  Zip2Sequence.swift
//  Sudoku
//
//  Created by 박재우 on 12/8/23.
//

import Foundation

extension Zip2Sequence where Sequence1.Element: Collection, Sequence2.Element: Collection {
    func compactMapMatrix<T>(
        _ transform: (
            Sequence1.Element.Element,
            Sequence2.Element.Element
        ) -> T?
    ) -> [[T?]] {
        self.map { sequencePair in
            zip(sequencePair.0, sequencePair.1).compactMap { elements in
                transform(elements.0, elements.1)
            }
        }
    }
}
