//
//  PublisherSpy.swift
//  MoiveDBMVVMTests
//
//  Created by DjangoLin on 2024/1/12.
//

import Foundation
import Combine

// MARK: - Public

extension Publisher {

    func spy(_ subscriptions: inout Set<AnyCancellable>) -> PublisherSpy<Output> {
        let spy = PublisherSpy<Output>()
        
        sink(receiveCompletion: { completion in
            switch completion {
            case .finished:
                spy.setCompleted()
                break
            case .failure(let encounteredError):
                spy.setError(error: encounteredError)
                spy.setCompleted()
            }
        }, receiveValue: { value in
            spy.append(value: value)
        }).store(in: &subscriptions)
        
        return spy
    }
}

// MARK: - PublisherSpy

class PublisherSpy<Output> {

    // MARK: - Properties

    private(set) var values: [Output]
    private(set) var error: Error?
    private(set) var completed: Bool

    // MARK: - Fileprivate

    // MARK: - Initializers

    fileprivate init() {
        self.values = []
        self.error = nil
        self.completed = false
    }

    // MARK: - Methods

    fileprivate func append(value: Output) {
        values.append(value)
    }

    fileprivate func setError(error: Error) {
        self.error = error
    }

    fileprivate func setCompleted() {
        completed = true
    }
}
