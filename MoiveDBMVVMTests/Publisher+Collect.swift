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
        // This time, we use Swift's Result type to keep track
        // of the result of our Combine pipeline:
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

        // Just like before, we await the expectation that we
        // created at the top of our test, and once done, we
        // also cancel our cancellable to avoid getting any
        // unused variable warnings:
        await fulfillment(of: [expectation], timeout: timeout)
        cancellable.cancel()

        // Here we pass the original file and line number that
        // our utility was called at, to tell XCTest to report
        // any encountered errors at that original call site:
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
