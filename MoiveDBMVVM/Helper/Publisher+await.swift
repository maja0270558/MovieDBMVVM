//
//  Publisher+await.swift
//  MoiveDBMVVM
//
//  Created by DjangoLin on 2024/1/3.
//

import Foundation
import Combine

extension Publisher {
    
    func awaitHandleOutput(_ receiveOutput: @escaping (Output) async -> Void) -> AnyPublisher<Output, Failure> {
        self.await { output in
            await receiveOutput(output)
            return output
        }
    }
    
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
    
    func awaitFilter(_ filter: @escaping (Output) async -> Bool) -> AnyPublisher<Output, Failure> {
        flatMap { value -> Future<Output, Failure> in
            Future { promise in
                Task {
                    let filterResult = await filter(value)
                    if filterResult {
                        promise(.success(value))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
