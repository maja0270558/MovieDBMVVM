//
//  HttpClientLive.swift
//  MoiveDBMVVM
//
//  Created by DjangoLin on 2023/12/19.
//

import Foundation
extension HttpClient {
    static let live: Self = .init(
        request: { endpoint in
            var urlComponents = URLComponents()
            urlComponents.scheme = endpoint.scheme
            urlComponents.host = endpoint.host
            urlComponents.path = "\(endpoint.host)\(endpoint.path)"
            urlComponents.queryItems = endpoint.query

            guard let url = urlComponents.url else {
                throw RequestError.invalidURL
            }

            var request = URLRequest(url: url)
            request.httpMethod = endpoint.method.rawValue
            request.allHTTPHeaderFields = endpoint.header

            if let body = endpoint.body {
                request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
            }

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

