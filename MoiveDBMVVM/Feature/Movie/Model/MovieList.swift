//
//  MovieList.swift
//  MoiveDBMVVM
//
//  Created by DjangoLin on 2024/1/4.
//

import Foundation

struct MovieList: Codable {
    let page: Int
    let results: [Movie]
    let totalPages, totalResults: Int
    
    struct Movie: Codable, Equatable, Hashable {
        let adult: Bool
        let backdropPath: String?
        let id: Int
        let originalLanguage: String
        let originalTitle, overview: String
        let popularity: Double
        let posterPath, releaseDate, title: String?
        let video: Bool
        let voteAverage: Double
        let voteCount: Int
    }
}
