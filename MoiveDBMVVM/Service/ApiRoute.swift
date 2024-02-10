//
//  ApiRoute.swift
//  MoiveDBMVVM
//
//  Created by DjangoLin on 2024/1/30.
//

import Combine
import Foundation

struct BaseEndpoint: Endpoint {
    var path: String { return "" }
    var method: RequestMethod { return .GET }
    var header: [String: String]? = nil
    var body: [String: String]? = nil
}

extension ApiRoute.MovieEndpoint: Endpoint {
    var path: String {
        switch self {
        case .nowPlaying:
            return "movie/now_playing"
        case .detail(let id):
            return "movie/\(id)"
        }
    }

    var query: [URLQueryItem]? {
        switch self {
        case .nowPlaying(let page):
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

@dynamicMemberLookup
public enum ApiRoute: Equatable {
    case movie(MovieEndpoint)
    public enum MovieEndpoint: Equatable, Sendable {
        case nowPlaying(page: Int)
        case detail(id: Int)
    }

    subscript<T>(dynamicMember member: KeyPath<Endpoint, T>) -> T {
        switch self {
        case .movie(let endpoint):
            return endpoint[keyPath: member]
        }
    }
}

extension ApiRoute {
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

extension ApiRoute {
    var scheme: String { return "https" }
    var host: String { return "api.themoviedb.org" }
    var defaultHeaders: [String: String] {
        return [
            "accept": "application/json",
            "Authorization": "***REMOVED***"
        ]
    }
}
