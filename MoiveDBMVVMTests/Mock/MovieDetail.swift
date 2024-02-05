//
//  MovieDetail.swift
//  MoiveDBMVVMTests
//
//  Created by DjangoLin on 2024/2/5.
//

import Foundation
@testable import MoiveDBMVVM

extension MovieDetail {
    static let mock: Self = .init(adult: false,
                                  backdropPath: "mock path",
                                  id: 0,
                                  originalLanguage: "en",
                                  originalTitle: "mock",
                                  overview: "mock overview",
                                  popularity: 1000,
                                  posterPath: "mock poster path",
                                  releaseDate: "2024/01/01")
}
