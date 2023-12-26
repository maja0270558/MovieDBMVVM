//
//  MovieListClientLive.swift
//  MoiveDBMVVM
//
//  Created by DjangoLin on 2023/12/19.
//

import Foundation

extension MovieClient {
    static var live: Self = .init(
        fetchPopular: { page in
            try await APIClient.current.request(serverRoute: MovieEndpoint.popular(page: page), as: MovieList.self)
        },
        fetchNowPlaying: { page in
            try await APIClient.current.request(serverRoute: MovieEndpoint.nowPlaying(page: page), as: MovieList.self)
        },
        fetchUpcomming: { page in
            try await APIClient.current.request(serverRoute: MovieEndpoint.upcomming(page: page), as: MovieList.self)
        },
        fetchDetail: { id in
            try await APIClient.current.request(serverRoute: MovieEndpoint.movieDetail(id: id ), as: MovieDetail.self)
        })
}

enum MovieEndpoint {
    case popular(page: Int)
    case upcomming(page: Int)
    case nowPlaying(page: Int)
    case movieDetail(id: Int)
}

extension MovieEndpoint: Endpoint {
    var path: String {
        switch self {
        case .popular:
            return "movie/popular"
        case .upcomming:
            return "movie/upcomming"
        case .nowPlaying:
            return "movie/nowplaying"
        case .movieDetail(let id):
            return "movie/\(id)"
        }
    }

    var query: [URLQueryItem]? {
        switch self {
        case .popular(let page), .upcomming(let page), .nowPlaying(let page):
            return [
                URLQueryItem(name: "language", value: "en-US"),
                URLQueryItem(name: "page", value: "\(page)")
            ]
        case .movieDetail:
            return [
                URLQueryItem(name: "language", value: "en-US")
            ]
        }
    }

    var method: RequestMethod { return .GET }
    var header: [String: String]? { return [:] }
    var body: [String: String]? { return nil }
}
