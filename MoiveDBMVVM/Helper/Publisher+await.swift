//
//  Publisher+await.swift
//  MoiveDBMVVM
//
//  Created by DjangoLin on 2024/1/3.
//

import Foundation
import Combine

extension Publisher {
    func `await`<T>(_ transform: @escaping (Output) async -> T) -> AnyPublisher<T, Failure> {
        flatMap { value -> Future<T, Failure> in
            Future { promise in
                Task {
                    let result = await transform(value)
                    promise(.success(result))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
