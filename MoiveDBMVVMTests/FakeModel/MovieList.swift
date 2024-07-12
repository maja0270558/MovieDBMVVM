//
//  MovieList.swift
//  MoiveDBMVVMTests
//
//  Created by DjangoLin on 2024/1/16.
//

import Foundation
@testable import MoiveDBMVVM

extension MovieList {
    static func fake(page: Int) -> Self {
        return .init(page: page,
                     results: [.fake, .fake, .fake],
                     totalPages: 3,
                     totalResults: 3)
    }
}

extension MovieList.Movie {
    static let fake: Self = .init(adult: false,
                                  backdropPath: nil,
                                  id: 1,
                                  originalLanguage: "en",
                                  originalTitle: "fake movie",
                                  overview: "noop",
                                  popularity: 0,
                                  posterPath: "noop",
                                  releaseDate: "",
                                  title: "fake title",
                                  video: false,
                                  voteAverage: 0,
                                  voteCount: 0)
}
