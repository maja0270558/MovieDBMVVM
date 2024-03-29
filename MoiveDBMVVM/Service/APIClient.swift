//
//  HttpClient.swift
//  MoiveDBMVVM
//
//  Created by DjangoLin on 2023/12/19.
//

import Combine
import Foundation
public struct ApiClient {

    public var sessionDataTaskPublisher: @Sendable (ApiRoute) throws -> AnyPublisher<(data: Data, response: URLResponse), URLError>

    public func request<A: Decodable>(
        serverRoute route: ApiRoute,
        as: A.Type
    ) -> AnyPublisher<Result<A, Error>, Never> {
  
        let publisher = try! self.sessionDataTaskPublisher(route)
            .tryMap { result in
                guard let response = result.response as? HTTPURLResponse, response.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return result.data
            }
            .decode(type: A.self, decoder: decoder)
            .map { .success($0) }
            .catch { error -> AnyPublisher<Result<A, Error>, Never> in
                return Just(.failure(error)).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()

        return publisher
    }
}

extension ApiClient {
    static let live: Self = .init(
        sessionDataTaskPublisher: { api in
            let configuration = URLSessionConfiguration.default
            configuration.waitsForConnectivity = false
            let session = URLSession(configuration: configuration)
            return try session.dataTaskPublisher(for: api.request()).eraseToAnyPublisher()
        }
    )

    public static let noop: Self = .init(
        sessionDataTaskPublisher: { api in
            fatalError("should not get in to this")
        }
    )
}

let decoder: JSONDecoder = {
    let jsonDecoder = JSONDecoder()
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    jsonDecoder.dateDecodingStrategy = .formatted(formatter)
    jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
    return jsonDecoder
}()
