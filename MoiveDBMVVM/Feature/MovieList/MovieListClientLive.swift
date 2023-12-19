//
//  MovieListClientLive.swift
//  MoiveDBMVVM
//
//  Created by DjangoLin on 2023/12/19.
//

import Foundation
extension MovieListClient {
    static var live: Self = {
        var client = HttpClient.live
        return .init(
            httpClient: client,
            fetchMovieList: { [client] in
                let result = try await client.request(MovieEndpoint.movieList)
                let data = try decoder.decode(MovieList.self, from: result.data)
                return data
            }
        )
    }()
}


enum MovieEndpoint {
    case movieList
}

extension MovieEndpoint: Endpoint {
    var path: String { return "movie" }
    var method: RequestMethod { return .GET }
    var header: [String : String]? { return [:] }
    var body: [String : String]? { return nil }
}
