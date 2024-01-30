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

    func makeSUT(_ updateValuesForOperation: (inout DependencyValues) -> Void) -> MovieViewModel {
        let viewModel = withDependencies {
            updateValuesForOperation(&$0)
            $0.mainQueue = .immediate
        } operation: {
            MovieViewModel()
        }
        return viewModel
    }

    func testBadConnection() {
        let viewModel = makeSUT {
            $0.mainQueue = .immediate
            $0.reachability = .unsatisfied
        }

        let movie = viewModel.output.movies.spy(&cancellabble)
        let alert = viewModel.output.alertMessage.eraseToAnyPublisher().spy(&cancellabble)
        let isLoading = viewModel.output.isLoading.eraseToAnyPublisher().spy(&cancellabble)

        viewModel.input.loadMovie()
        XCTAssertEqual(movie.values, [[]])
        XCTAssertEqual(isLoading.values, [false, false])
        XCTAssertEqual(alert.values, ["The internet is down :["])
    }

    func testLoadMovieShouldIncreaseCurrentPage() {
        let viewModel = makeSUT {
            for page in 1 ... 10 {
                $0.api.override(route: .movie(.nowPlaying(page: page))) {
                    try OK(MovieList.mock(page: page))
                }
            }
        }

        viewModel.input.loadMovie()
        XCTAssertEqual(viewModel.state.currentPage, 1)
        viewModel.input.loadMovie()
        XCTAssertEqual(viewModel.state.currentPage, 2)
        viewModel.input.loadMovie()
        XCTAssertEqual(viewModel.state.currentPage, 3)
    }

    func testReloadShouldResetCurrentPage() {
        let viewModel = makeSUT {
            for page in 1 ... 10 {
                $0.api.override(route: .movie(.nowPlaying(page: page))) {
                    try OK(MovieList.mock(page: page))
                }
            }
        }

        viewModel.input.loadMovie()
        XCTAssertEqual(viewModel.state.currentPage, 1)
        viewModel.input.loadMovie()
        XCTAssertEqual(viewModel.state.currentPage, 2)
        viewModel.input.reload()
        XCTAssertEqual(viewModel.state.currentPage, 1)
    }

    func testLoadMovieShouldInvokeOnlyOnce() {
        let viewModel = makeSUT {
            for page in 1 ... 2 {
                $0.api.override(route: .movie(.nowPlaying(page: page))) {
                    self.counter += 1
                    return try OK(MovieList.mock(page: page))
                }
            }
        }

        viewModel.input.loadMovie()
        XCTAssertEqual(counter, 1)

        viewModel.input.loadMovie()
        XCTAssertEqual(counter, 2)
    }

    func testReloadMovieShouldInvokeOnlyOnce() {
        let viewModel = makeSUT {
            $0.api.override(route: .movie(.nowPlaying(page: 1))) {
                self.counter += 1
                return try OK(MovieList.mock(page: 1))
            }
        }

        viewModel.input.reload()
        XCTAssertEqual(counter, 1)

        viewModel.input.reload()
        XCTAssertEqual(counter, 2)
    }

    func testParsingFail() {
        let viewModel = makeSUT {
            $0.api.override(route: .movie(.nowPlaying(page: 1))) {
                try OK(
                    [
                        "deadbeaf": 0000
                    ]
                )
            }
        }

        let movie = viewModel.output.movies.spy(&cancellabble)
        let alert = viewModel.output.alertMessage.eraseToAnyPublisher().spy(&cancellabble)
        viewModel.input.loadMovie()
        XCTAssertEqual(movie.values, [[]])
        XCTAssertEqual(alert.values, ["The data couldn’t be read because it is missing."])
    }

    func testHappyPath() {
        let viewModel = makeSUT {
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
        }

        let movie = viewModel.output.movies.spy(&cancellabble)
        viewModel.input.loadMovie()
        XCTAssertEqual(movie.values.last?.last?.title, "Napoleon")
    }
}
