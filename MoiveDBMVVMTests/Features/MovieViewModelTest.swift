//
//  MovieViewModelTest.swift
//  MoiveDBMVVMTests
//
//  Created by DjangoLin on 2024/1/5.
//

import Combine
import Dependencies
@testable import MoiveDBMVVM
import XCTest

final class MovieViewModelTest: XCTestCase {
    fileprivate var counter = 0
    var cancellabble = Set<AnyCancellable>()
    
    func testBadConnection() {
        let viewModel = withDependencies {
            for page in 1 ... 10 {
                $0.api.override(route: .movie(.nowPlaying(page: page))) {
                    return try OK(MovieList.mock(page: page))
                }
            }
            
            $0.reachability = .unsatisfied
        } operation: {
            MovieViewModel()
        }
        
        viewModel.input.loadMovie()
    }

    func testLoadMovieShouldIncreaseCurrentPage() {
        let viewModel = withDependencies {
            for page in 1 ... 10 {
                $0.api.override(route: .movie(.nowPlaying(page: page))) {
                    return try OK(MovieList.mock(page: page))
                }
            }
        } operation: {
            MovieViewModel()
        }

        viewModel.input.loadMovie()
        XCTAssertEqual(viewModel.state.currentPage, 1)
        viewModel.input.loadMovie()
        XCTAssertEqual(viewModel.state.currentPage, 2)
        viewModel.input.loadMovie()
        XCTAssertEqual(viewModel.state.currentPage, 3)
    }

    func testReloadShouldResetCurrentPage() {
        let viewModel = withDependencies {
            for page in 1 ... 10 {
                $0.api.override(route: .movie(.nowPlaying(page: page))) {
                    return try OK(MovieList.mock(page: page))
                }
            }
        } operation: {
            MovieViewModel()
        }
        
        viewModel.input.loadMovie()
        XCTAssertEqual(viewModel.state.currentPage, 1)
        viewModel.input.loadMovie()
        XCTAssertEqual(viewModel.state.currentPage, 2)
        viewModel.input.reload()
        XCTAssertEqual(viewModel.state.currentPage, 1)
    }

    func testLoadMovieShouldInvokeOnlyOnce() {
        let viewModel = withDependencies {
            for page in 1 ... 2 {
                $0.api.override(route: .movie(.nowPlaying(page: page))) {
                    self.counter += 1
                    return try OK(MovieList.mock(page: page))
                }
            }
        } operation: {
            MovieViewModel()
        }
        
        viewModel.input.loadMovie()
        XCTAssertEqual(counter, 1)

        viewModel.input.loadMovie()
        XCTAssertEqual(counter, 2)
    }

    func testReloadMovieShouldInvokeOnlyOnce() {
        let viewModel = withDependencies {
            $0.api.override(route: .movie(.nowPlaying(page: 1))) {
                self.counter += 1
                return try OK(MovieList.mock(page: 1))
            }
        } operation: {
            MovieViewModel()
        }
        
        
        viewModel.input.reload()
        XCTAssertEqual(counter, 1)

        viewModel.input.reload()
        XCTAssertEqual(counter, 2)
    }


    func testParsingFail() {
        
        let viewModel = withDependencies {
            $0.api.override(route: .movie(.nowPlaying(page: 1))) {
                try OK(
                    [
                        "deadbeaf": 0000
                    ]
                )
            }
        } operation: {
            MovieViewModel()
        }
        
        let movie = viewModel.output.movies.spy(&cancellabble)
        let alert = viewModel.output.alertMessage.eraseToAnyPublisher().spy(&cancellabble)
        viewModel.input.loadMovie()
        XCTAssertEqual(movie.values, [[]])
        XCTAssertEqual(alert.values, ["The data couldn’t be read because it is missing."])
    }

    func testHappyPath() {
        let viewModel = withDependencies {
            $0.api.override(route: .movie(.nowPlaying(page: 1))) {
                try OK(
                    [
                        "dates": [
                            "maximum": "2024-01-17",
                            "minimum": "2023-12-06"
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
        } operation: {
            MovieViewModel()
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
        
        let movie = viewModel.output.movies.spy(&cancellabble)
        viewModel.input.loadMovie()
        XCTAssertEqual(movie.values, [[], [expectMovieResult]])
    }
}
