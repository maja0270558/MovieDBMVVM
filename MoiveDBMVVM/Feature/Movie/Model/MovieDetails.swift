//
//  MovieDetails.swift
//  MoiveDBMVVM
//
//  Created by DjangoLin on 2024/1/30.
//

import Foundation

struct MovieDetail: Codable, Equatable {
    var adult: Bool
    var backdropPath: String
    var id: Int
    var originalLanguage, originalTitle, overview: String
    var popularity: Double
    var posterPath: String
    var releaseDate: String
}

