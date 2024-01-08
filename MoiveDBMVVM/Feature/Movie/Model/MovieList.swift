//
//  MovieList.swift
//  MoiveDBMVVM
//
//  Created by DjangoLin on 2024/1/4.
//

import Foundation


// MARK: - Welcome
struct MovieList: Decodable {
    let dates: Dates
    let page: Int
    let results: [Movie]
    let totalPages, totalResults: Int
    
    // MARK: - Dates
    struct Dates: Decodable {
        let maximum, minimum: String
    }
    
    // MARK: - Result
    struct Movie: Decodable {
        let adult: Bool
        let backdropPath: String
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



