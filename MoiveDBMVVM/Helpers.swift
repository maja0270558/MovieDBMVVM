//
//  Helpers.swift
//  MoiveDBMVVM
//
//  Created by DjangoLin on 2023/12/27.
//

#if DEBUG
import Foundation
import Combine

public func OK<A: Encodable>(
    _ value: A, encoder: JSONEncoder = .init()
) throws -> (Data, URLResponse) {
    (
        try encoder.encode(value),
        HTTPURLResponse(
            url: URL(string: "/")!, statusCode: 200, httpVersion: nil, headerFields: nil
        )!
    )
}

public func OK(_ jsonObject: Any) throws -> (Data, URLResponse) {
    (
        try JSONSerialization.data(withJSONObject: jsonObject, options: []),
        HTTPURLResponse(
            url: URL(string: "/")!, statusCode: 200, httpVersion: nil, headerFields: nil
        )!
    )
}

public extension ApiClient {
    
    mutating func override(
        route  matchingRoute: Api,
        withPublisher response: @escaping @Sendable () throws -> AnyPublisher<(data: Data, response: URLResponse), URLError>
    )  {
        self.apiRequestPublisher = { [self] route in
            if route == matchingRoute {
                return try response()
            } else {
                return try self.apiRequestPublisher(route)
            }
        }
    }
    
    mutating func override(
        route matchingRoute: Api,
        withResponse response: @escaping @Sendable () async throws -> (Data, URLResponse)
    ) {
        self.apiRequest = { @Sendable [self] route in
            if route == matchingRoute {
                return try await response()
            } else {
                return try await self.apiRequest(route)
            }
        }
    }
}
#endif


