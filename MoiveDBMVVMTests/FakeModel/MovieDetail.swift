//
//  MovieDetail.swift
//  MoiveDBMVVMTests
//
//  Created by DjangoLin on 2024/2/5.
//

import Foundation
@testable import MoiveDBMVVM

extension MovieDetail {
    static let fake: Self = .init(adult: false,
                                  backdropPath: "fake path",
                                  id: 0,
                                  originalLanguage: "en",
                                  originalTitle: "fake",
                                  overview: "fake overview",
                                  popularity: 1000,
                                  posterPath: "fake poster path",
                                  releaseDate: "2024/01/01")
}
