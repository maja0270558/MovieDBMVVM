//
//  MovieList.swift
//  MoiveDBMVVM
//
//  Created by DjangoLin on 2024/1/4.
//

import Foundation


// MARK: - Welcome
struct MovieList: Codable {
    let page: Int
    let results: [Movie]
    let totalPages, totalResults: Int
    
    // MARK: - Dates
    struct Dates: Codable {
        let maximum, minimum: String
    }
    
    // MARK: - Result
    struct Movie: Codable {
        let adult: Bool
        let backdropPath: String?
        let id: Int
        let originalLanguage: String
        let originalTitle, overview: String
        let popularity: Double
        let posterPath, releaseDate, title: String
        let video: Bool
        let voteAverage: Double
        let voteCount: Int
    }
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
