//
//  MovieListClientLive.swift
//  MoiveDBMVVM
//
//  Created by DjangoLin on 2023/12/19.
//

import Foundation

//extension MovieClient {
//    
//    static var live: Self = .init(
//        fetchPopular: { page in
//            try await APIClient.current.request(serverRoute: MovieEndpoint.popular(page: page), as: MovieList.self)
//        },
//        fetchNowPlaying: { page in
//            try await APIClient.current.request(serverRoute: MovieEndpoint.nowPlaying(page: page), as: MovieList.self)
//        },
//        fetchUpcomming: { page in
//            try await APIClient.current.request(serverRoute: MovieEndpoint.upcomming(page: page), as: MovieList.self)
//        },
//        fetchDetail: { id in
//            try await APIClient.current.request(serverRoute: MovieEndpoint.movieDetail(id: id ), as: MovieDetail.self)
//        })
//}
//
