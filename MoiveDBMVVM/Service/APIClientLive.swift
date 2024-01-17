//
//  HttpClientLive.swift
//  MoiveDBMVVM
//
//  Created by DjangoLin on 2023/12/19.
//

import Combine
import Foundation
extension ApiClient {
    static let live: Self = .init(
        sessionDataTaskPublisher: { api in
            try URLSession.shared.dataTaskPublisher(for: api.request()).eraseToAnyPublisher()
        }
    )

    public static let noop: Self = .init(
        sessionDataTaskPublisher: { api in
            fatalError("should not get in to this")
        }
    )
}

extension Task where Failure == Never {
    /// An async function that never returns.
    static func never() async throws -> Success {
        for await element in AsyncStream<Success>.never {
            return element
        }
        throw _Concurrency.CancellationError()
    }
}

extension AsyncStream {
    static var never: Self {
        Self { _ in }
    }
}
