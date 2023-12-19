//
//  MovieListClientLive.swift
//  MoiveDBMVVM
//
//  Created by DjangoLin on 2023/12/19.
//

import Foundation
extension MovieListClient {
    static var live: Self = {
        var
        return .init(
            httpClient: <#T##HttpClient#>,
            fetchMovieList: <#T##() async throws -> MovieList#>
        )
    }()
}
