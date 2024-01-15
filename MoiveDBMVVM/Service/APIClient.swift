//
//  HttpClient.swift
//  MoiveDBMVVM
//
//  Created by DjangoLin on 2023/12/19.
//

import Combine
import Foundation
public struct ApiClient {

    public var sessionDataTaskPublisher: @Sendable (Api) throws -> AnyPublisher<(data: Data, response: URLResponse), URLError>

    public func request<A: Decodable>(
        serverRoute route: Api,
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
                switch error {
                case is DecodingError:
                    return Just(.failure(RequestError.decode)).eraseToAnyPublisher()
                case is URLError:
                    return Just(.failure(RequestError.invalidURL)).eraseToAnyPublisher()
                default:
                    return Just(.failure(RequestError.unknown)).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()

        return publisher
    }
}

let decoder: JSONDecoder = {
    let jsonDecoder = JSONDecoder()
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    jsonDecoder.dateDecodingStrategy = .formatted(formatter)
    jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
    return jsonDecoder
}()
