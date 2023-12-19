//
//  MovieListClient.swift
//  MoiveDBMVVM
//
//  Created by DjangoLin on 2023/12/19.
//

import Foundation

struct MovieListClient {
    var httpClient: HttpClient
    var fetchMovieList: @Sendable () async throws -> MovieList
}

struct MovieList: Decodable {}
