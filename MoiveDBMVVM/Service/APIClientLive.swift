//
//  HttpClientLive.swift
//  MoiveDBMVVM
//
//  Created by DjangoLin on 2023/12/19.
//

import Foundation

extension ApiClient {
    static let current: Self = .init { api in
        return try await URLSession.shared.data(for: api.request())
    }
    
    public static let noop: Self = .init(apiRequest: { _ in
        try await Task.never()
    })

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
