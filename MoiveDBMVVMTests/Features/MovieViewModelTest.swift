//
//  MovieViewModelTest.swift
//  MoiveDBMVVMTests
//
//  Created by DjangoLin on 2024/1/5.
//

import Combine
@testable import MoiveDBMVVM
import XCTest

final class MovieViewModelTest: XCTestCase {
    fileprivate var counter = 0
    var vm = MovieViewModel()
    var cancellabble = Set<AnyCancellable>()
    override class func setUp() {
        super.setUp()
        Current = .mock
        for page in 1...10 {
            Current.api.override(route: .movie(.nowPlaying(page: page))) {
                return try OK(MovieList.mock)
            }
        }
    }
    
    func testLoadMovieShouldIncreaseCurrentPage() {
        vm.input.loadMovie()
        XCTAssertEqual(vm.state.currentPage, 1)
        vm.input.loadMovie()
        XCTAssertEqual(vm.state.currentPage, 2)
        vm.input.loadMovie()
        XCTAssertEqual(vm.state.currentPage, 3)
    }
    
    func testReloadShouldResetCurrentPage() {
        vm.input.loadMovie()
        XCTAssertEqual(vm.state.currentPage, 1)
        vm.input.loadMovie()
        XCTAssertEqual(vm.state.currentPage, 2)
        vm.input.reload()
        XCTAssertEqual(vm.state.currentPage, 1)
    }
    
    func testLoadMovieShouldInvokeOnlyOnce() {
        Current.api.override(route: .movie(.nowPlaying(page: 1))) { [weak self] in
            self?.counter += 1
            return try OK(MovieList.mock)
        }
        
        Current.api.override(route: .movie(.nowPlaying(page: 2))) { [weak self] in
            self?.counter += 1
            return try OK(MovieList.mock)
        }
        vm.input.loadMovie()
        XCTAssertEqual(counter, 1)

        vm.input.loadMovie()
        XCTAssertEqual(counter, 2)
    }
    
    func testReloadMovieShouldInvokeOnlyOnce() {
        Current.api.override(route: .movie(.nowPlaying(page: 1))) { [weak self] in
            self?.counter += 1
            return try OK(MovieList.mock)
        }
        
        Current.api.override(route: .movie(.nowPlaying(page: 2))) { [weak self] in
            self?.counter += 1
            return try OK(MovieList.mock)
        }
        vm.input.reload()
        XCTAssertEqual(counter, 1)

        vm.input.reload()
        XCTAssertEqual(counter, 2)
    }
    
    func testHappyPath() {
        Current.api.override(route: .movie(.nowPlaying(page: 1))) {
            return try OK(
                [
                      "dates": [
                        "maximum" : "2024-01-17",
                        "minimum" : "2023-12-06"
                      ],
                      "page": 1,
                      "results": [
                        [
                          "adult": false,
                          "backdrop_path": "/f1AQhx6ZfGhPZFTVKgxG91PhEYc.jpg",
                          "genre_ids": [
                            36,
                            10752,
                            18
                          ],
                          "id": 753342,
                          "original_language": "en",
                          "original_title": "Napoleon",
                          "overview": "An epic that details the checkered rise and fall of French Emperor Napoleon Bonaparte and his relentless journey to power through the prism of his addictive, volatile relationship with his wife, Josephine.",
                          "popularity": 2998.164,
                          "poster_path": "/jE5o7y9K6pZtWNNMEw3IdpHuncR.jpg",
                          "release_date": "2023-11-22",
                          "title": "Napoleon",
                          "video": false,
                          "vote_average": 6.476,
                          "vote_count": 1154
                        ]
                      ],
                      "total_pages": 154,
                      "total_results": 3064
                ]
            )
        }
        
        let expectMovieResult = MovieList.Movie(adult: false,
                                                backdropPath: "/f1AQhx6ZfGhPZFTVKgxG91PhEYc.jpg",
                                                id: 753342,
                                                originalLanguage: "en",
                                                originalTitle: "Napoleon",
                                                overview: "An epic that details the checkered rise and fall of French Emperor Napoleon Bonaparte and his relentless journey to power through the prism of his addictive, volatile relationship with his wife, Josephine.",
                                                popularity: 2998.164,
                                                posterPath: "/jE5o7y9K6pZtWNNMEw3IdpHuncR.jpg",
                                                releaseDate: "2023-11-22",
                                                title: "Napoleon",
                                                video: false,
                                                voteAverage: 6.476,
                                                voteCount: 1154)
        
        let movie = vm.output.movies.spy(&cancellabble)
        vm.input.loadMovie()
        XCTAssertEqual(movie.values, [[], [expectMovieResult]])
    }


//    func expect(override: (desc: String,
//                           route: Api,
//                           with: Encodable),
//                when action: () -> Void,
//                then afterFullfill: () -> Void) async
//    {
//        let expected = XCTestExpectation(description: override.desc)
//        Current.api.override(route: override.route) {
//            expected.fulfill()
//            return try OK(
//                override.with
//            )
//        }
//        action()
//        await fulfillment(of: [expected], timeout: 10)
//        afterFullfill()
//    }
//
//    func testMovieViewModel_loadPageCorrect() async {
//        await expect(override: (desc: "Override now playing page 1",
//                                route: .movie(.nowPlaying(page: 1)),
//                                with: MovieList(
//                                    page: 1,
//                                    results: [.mock],
//                                    totalPages: 3,
//                                    totalResults: 1
//                                ))) {
//            vm.input.loadMovie()
//        } then: {
//            print(vm.output.movies.value)
//            print(vm.currentMovieList?.page)
//
//        }
//
//        await expect(override: (desc: "Override now playing page 2",
//                                route: .movie(.nowPlaying(page: 2)),
//                                with: MovieList(
//                                    page: 2,
//                                    results: [.mock, .mock],
//                                    totalPages: 3,
//                                    totalResults: 1
//                                ))) {
//            vm.input.loadMovie()
//        } then: {
//            print(vm.output.movies.value)
//            print(vm.currentMovieList?.page)
//
//        }
//    }
    

//    func testMovieViewModel_initLoad_pageShouldEqualToOne() async throws {
//        let spyValue = vm.output.movies.spy(&cancellabble)
//
//        Current.api.override(route: .movie(.nowPlaying(page: 1))) {
//            print("matchingRoute : 1)")
//
//            return try OK(
//                MovieList(
//                    page: 1,
//                    results: [.mock],
//                    totalPages: 3,
//                    totalResults: 1
//                )
//            )
//        }
//
//        vm.input.loadMovie()
//
////        vm.input.loadMovie(category: .nowPlaying)
//        print("😁")
//
////        print("page: \(vm.state.currentPage(.nowPlaying))")
//        print(spyValue.values)
//        Current.api.override(route: .movie(.nowPlaying(page: 2))) {
//            print("matchingRoute : 2)")
//
//            return try OK(
//                MovieList(
//                    page: 2,
//                    results: [.mock],
//                    totalPages: 3,
//                    totalResults: 1
//                )
//            )
//        }
//        vm.input.loadMovie()
//
//        Current.api.override(route: .movie(.nowPlaying(page: 3))) {
//            print("matchingRoute : 3)")
//
//            return try OK(
//                MovieList(
//                    page: 3,
//                    results: [.mock],
//                    totalPages: 3,
//                    totalResults: 1
//                )
//            )
//        }
//        print("😁")
//        vm.input.reload()
//
////        print("page: \(vm.state.currentPage(.nowPlaying))")
//        print(spyValue.values)
//
//        print("😁")
//        vm.input.loadMovie()
//        vm.input.loadMovie()
//        vm.input.loadMovie()
//        vm.input.loadMovie()
//
////        print(spyValue.values)
//    }
}
