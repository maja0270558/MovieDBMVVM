//
//  Endpoint.swift
//  MoiveDBMVVM
//
//  Created by DjangoLin on 2023/12/19.
//

import Combine
import Foundation

enum RequestMethod: String {
    case DELETE
    case GET
    case PATCH
    case POST
    case PUT
}

protocol Endpoint {
    var path: String { get }
    var method: RequestMethod { get }
    var header: [String: String]? { get }
    var body: [String: String]? { get }
    var query: [URLQueryItem]? { get }
}

extension Endpoint {
    var query: [URLQueryItem]? { return [] }
}

@dynamicMemberLookup
public enum Api: Equatable {
    var scheme: String { return "https" }
    var host: String { return "api.themoviedb.org" }
    var defaultHeaders: [String: String] {
        return [
            "accept": "application/json",
            "Authorization": "***REMOVED***"
        ]
    }

    case movie(Movie)
    case login

    public enum Movie: Equatable, Sendable {
        case popular(page: Int)
        case upcoming(page: Int)
        case nowPlaying(page: Int)
        case detail(id: Int)
    }

    subscript<T>(dynamicMember member: KeyPath<Endpoint, T>) -> T {
        switch self {
        case .movie(let endpoint):
            return endpoint[keyPath: member]
        case .login:
            return BaseEndpoint()[keyPath: member]
        }
    }

    func requestPublisher() -> AnyPublisher<URLRequest, URLError> {
        return Future<URLRequest, URLError> { promise in
            do {
                let request = try self.request()
                promise(.success(request))
            } catch {
                promise(.failure(error as! URLError))
            }
        }
        .eraseToAnyPublisher()
    }

    func request() throws -> URLRequest {
        var urlComponents = URLComponents()
        urlComponents.scheme = self.scheme
        urlComponents.host = self.host
        urlComponents.path = "/3/\(self.path)"
        urlComponents.queryItems = self.query

        guard let url = urlComponents.url else {
            throw URLError(.unsupportedURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = self.method.rawValue

        let allHTTPHeaderFields = self.header?.merging(defaultHeaders, uniquingKeysWith: { _, new in
            new
        })

        request.allHTTPHeaderFields = allHTTPHeaderFields

        if let body = self.body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        }

        return request
    }
}

struct BaseEndpoint: Endpoint {
    var path: String { return "" }

    var method: RequestMethod { return .GET }

    var header: [String: String]? = nil

    var body: [String: String]? = nil
}

extension Api.Movie: Endpoint {
    var path: String {
        switch self {
        case .popular:
            return "movie/popular"
        case .upcoming:
            return "movie/upcoming"
        case .nowPlaying:
            return "movie/now_playing"
        case .detail(let id):
            return "movie/\(id)"
        }
    }

    var query: [URLQueryItem]? {
        switch self {
        case .popular(let page), .upcoming(let page), .nowPlaying(let page):
            return [
                URLQueryItem(name: "language", value: "en-US"),
                URLQueryItem(name: "page", value: "\(page)")
            ]
        case .detail:
            return [
                URLQueryItem(name: "language", value: "en-US")
            ]
        }
    }

    var method: RequestMethod { return .GET }
    var header: [String: String]? { return [:] }
    var body: [String: String]? { return nil }
}
