//
//  Publisher+Collect.swift
//  MoiveDBMVVMTests
//
//  Created by DjangoLin on 2024/1/12.
//

import Foundation
import Combine
import XCTest

extension XCTestCase {
    func awaitPublisher<T: Publisher>(
        _ publisher: T,
        timeout: TimeInterval = 10,
        file: StaticString = #file,
        line: UInt = #line
    ) async -> T.Output {

        var result: Result<T.Output, Error>?
        let expectation = self.expectation(description: "Awaiting publisher")

        let cancellable = publisher.sink(
            receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    result = .failure(error)
                case .finished:
                    break
                }

                expectation.fulfill()
            },
            receiveValue: { value in
                result = .success(value)
            }
        )

        await fulfillment(of: [expectation], timeout: timeout)
        cancellable.cancel()

        let unwrappedResult = try! XCTUnwrap(
            result,
            "Awaited publisher did not produce any output",
            file: file,
            line: line
        )

        return try! unwrappedResult.get()
    }
}

extension Published.Publisher {
    func collectNext(_ count: Int) -> AnyPublisher<[Output], Never> {
        self.dropFirst()
            .collect(count)
            .first()
            .eraseToAnyPublisher()
    }
}

extension PassthroughSubject {
    func collectNext(_ count: Int) -> AnyPublisher<[Output], Failure> {
        self.collect(count)
            .first()
            .eraseToAnyPublisher()
    }
}

extension AnyPublisher {
    func collectNext(_ count: Int) -> AnyPublisher<[Output], Failure> {
        self.collect(count)
            .first()
            .eraseToAnyPublisher()
    }
}

extension CurrentValueSubject {
    func collectNext(_ count: Int) -> AnyPublisher<[Output], Failure> {
        self.dropFirst()
            .collect(count)
            .first()
            .eraseToAnyPublisher()
    }
}
