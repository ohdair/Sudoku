//
//  Networking.swift
//  Sudoku
//
//  Created by 박재우 on 11/22/23.
//

import Foundation
import RxSwift

struct Networking {
    static private let endpoint = "https://sudoku-api.vercel.app/api/dosuku"

    static private func loadData(complition: @escaping (Result<SudokuData, NetworkError>) -> Void) {
        guard let url = URL(string: endpoint) else {
            complition(.failure(.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                complition(.failure(.transportError))
            }

            guard let data else {
                complition(.failure(.missingData))
                return
            }

            guard let response = response as? HTTPURLResponse,
                  (200...299) ~= response.statusCode
            else {
                complition(.failure(.serverError))
                return
            }

            guard let decodedData = try? JSONDecoder().decode(SudokuDataDTO.self, from: data) else {
                complition(.failure(.decodingError))
                return
            }

            complition(.success(decodedData.fetch()))
        }
        .resume()
    }

    static func request() -> Observable<SudokuData> {
        return Observable.create { (observe) -> Disposable in
            self.loadData { result in
                switch result {
                case .success(let success):
                    observe.onNext(success)
                case .failure(let failure):
                    observe.onError(failure)
                }
                observe.onCompleted()
            }
            return Disposables.create()
        }
    }
}
