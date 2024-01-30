//
//  Helpers.swift
//  MoiveDBMVVM
//
//  Created by DjangoLin on 2023/12/27.
//

#if DEBUG
import Combine
import Foundation

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
        route matchingRoute: ApiRoute,
        withResponse response: @escaping @Sendable () throws -> (Data, URLResponse)
    ) {
        self.sessionDataTaskPublisher = { [self] route in
            if route == matchingRoute {
                return Just(
                    try response()
                )
                .setFailureType(to: URLError.self)
                .eraseToAnyPublisher()
            } else {
                return try self.sessionDataTaskPublisher(route)
            }
        }
    }
}
#endif
