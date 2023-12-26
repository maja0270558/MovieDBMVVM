//
//  MovieListClient.swift
//  MoiveDBMVVM
//
//  Created by DjangoLin on 2023/12/19.
//

import Foundation

struct MovieClient {
    var fetchPopular: @Sendable (_ page: Int) async throws -> MovieList
    var fetchNowPlaying: @Sendable (_ page: Int) async throws -> MovieList
    var fetchUpcomming: @Sendable (_ page: Int) async throws -> MovieList
    var fetchDetail: @Sendable (_ id: Int) async throws -> MovieDetail
}

struct MovieList: Decodable {}
struct MovieDetail: Decodable {}
