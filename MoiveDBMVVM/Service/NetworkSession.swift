//
//  NetworkSession.swift
//  MoiveDBMVVM
//
//  Created by DjangoLin on 2023/12/26.
//

import Foundation

struct NetworrkSession {
    var request: @Sendable (URLRequest) async throws -> (data: Data, response: URLResponse)
    var createRequest: @Sendable (Endpoint) throws -> URLRequest
}

extension NetworrkSession {
    static let live: Self = .init(
        request: { request in
            do {
                let result = try await URLSession.shared.data(for: request)
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
                throw RequestError.unknown
            }
        },
        createRequest: {
            try $0.request()
        }
    )
}

extension Endpoint {
    func request() throws -> URLRequest {
        var urlComponents = URLComponents()
        urlComponents.scheme = self.scheme
        urlComponents.host = self.host
        urlComponents.path = "/3/\(self.path)"
        urlComponents.queryItems = self.query

        guard let url = urlComponents.url else {
            throw RequestError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = self.method.rawValue
        request.allHTTPHeaderFields = self.header

        if let body = self.body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        }
        return request
    }
}
