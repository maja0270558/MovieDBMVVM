//
//  HttpClient.swift
//  MoiveDBMVVM
//
//  Created by DjangoLin on 2023/12/19.
//

import Combine
import Foundation
public struct ApiClient {
    public var apiRequest: @Sendable (Api) async throws -> (Data, URLResponse)
    public var apiRequestPublisher: @Sendable (Api) throws -> AnyPublisher<(data: Data, response: URLResponse), URLError>

    public func request(
        serverRoute route: Api
    ) async throws -> (Data, URLResponse) {
        do {
            let result = try await self.apiRequest(route)
            #if DEBUG
            let status = (result.1 as? HTTPURLResponse)?.statusCode
            let url = (result.1 as? HTTPURLResponse)?.url?.absoluteString
            print(
                """
                ----------------------------

                API: route: \(route)

                response url: \(url ?? "")

                status: \(status ?? 0)

                receive data: \(String(decoding: result.0, as: UTF8.self))

                ----------------------------
                """
            )
            #endif

            guard let response = result.1 as? HTTPURLResponse else {
                throw RequestError.noResponse
            }

            switch response.statusCode {
            case 200 ... 299:
                return result
            case 401:
                throw RequestError.unauthorized
            default:
                throw RequestError.unexpectedStatusCode
            }
        } catch {
            throw error
        }
    }

    public func request<A: Decodable>(
        serverRoute route: Api,
        as: A.Type
    ) -> AnyPublisher<Result<A, Error>, Never> {
        
        let publisher = try! self.apiRequestPublisher(route)
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

    public func request<A: Decodable>(
        serverRoute route: Api,
        as: A.Type
    ) async -> Result<A, Error> {
        do {
            let (data, _) = try await request(serverRoute: route)
            return .success(try apiDecode(A.self, from: data))
        } catch {
            return .failure(error)
        }
    }
}

public func apiDecode<A: Decodable>(
    _ type: A.Type,
    from data: Data
) throws -> A {
    do {
        return try decoder.decode(A.self, from: data)
    } catch let decodingError {
        throw decodingError
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
