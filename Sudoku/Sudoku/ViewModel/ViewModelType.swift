//
//  ViewModelType.swift
//  Sudoku
//
//  Created by 박재우 on 12/18/23.
//

import Foundation
import RxSwift

protocol ViewModelType {
    associatedtype Input
    associatedtype Output

    func transform(input: Input) -> Output
}
