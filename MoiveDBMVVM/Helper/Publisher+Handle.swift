//
//  Publisher+Handle.swift
//  MoiveDBMVVM
//
//  Created by DjangoLin on 2024/1/15.
//

import Foundation
import Combine

extension Publisher {
    func handleOutput(_ receiveOutput: @escaping (Output) -> Void) -> Publishers.HandleEvents<Self> {
        handleEvents(receiveOutput: receiveOutput)
    }

    func handleError(_ receiveError: @escaping ((Self.Failure) -> Void)) -> Publishers.HandleEvents<Self> {
        handleEvents(receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
                receiveError(error)
            case .finished:
                ()
            }
        })
    }
}
