//
//  MovieList.swift
//  MoiveDBMVVMTests
//
//  Created by DjangoLin on 2024/1/16.
//

import Foundation
@testable import MoiveDBMVVM

extension MovieList {
    static let mock: Self = .init(page: 1,
                                  results: [.mock, .mock, .mock],
                                  totalPages: 3,
                                  totalResults: 3)
}

extension MovieList.Movie {
    static let mock: Self = .init(adult: false,
                                  backdropPath: nil,
                                  id: 1,
                                  originalLanguage: "en",
                                  originalTitle: "mock movie",
                                  overview: "noop",
                                  popularity: 0,
                                  posterPath: "noop",
                                  releaseDate: "",
                                  title: "mock title",
                                  video: false,
                                  voteAverage: 0,
                                  voteCount: 0)
}
