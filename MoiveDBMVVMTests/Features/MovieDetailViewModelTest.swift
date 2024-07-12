//
//  MovieDetailViewModelTest.swift
//  MoiveDBMVVMTests
//
//  Created by DjangoLin on 2024/2/5.
//

import Combine
import Dependencies
@testable import MoiveDBMVVM
import XCTest

final class MovieDetailViewModelTest: XCTestCase {
    var cancellabble = Set<AnyCancellable>()
    let fakeMovieID = 0
    var counter = 0
    
    func makeSUT(id: Int, _ updateValuesForOperation: (inout DependencyValues) -> Void) -> MovieDetailViewModel {
        let viewModel = withDependencies {
            updateValuesForOperation(&$0)
            $0.mainQueue = .immediate
        } operation: {
            MovieDetailViewModel(movieId: id)
        }
        return viewModel
    }

    
    
    func testBadConnection() {
        let viewModel = makeSUT(id: fakeMovieID) {
            $0.reachability = .unsatisfied
        }

        let detail = viewModel.output.$detail.spy(&cancellabble)
        let alert = viewModel.output.alertMessage.eraseToAnyPublisher().spy(&cancellabble)

        viewModel.input.viewDidLoad()
        XCTAssertEqual(detail.values, [nil])
        XCTAssertEqual(alert.values, ["The internet is down :["])
    }

    func testLoadMovieDetailShouldInvokeOnlyOnce() {
        let viewModel = makeSUT(id: fakeMovieID) {
            $0.api.override(route: .movie(.detail(id: fakeMovieID))) {
                self.counter += 1
                return try OK(MovieDetail.fake)
            }
        }

        viewModel.input.viewDidLoad()
        XCTAssertEqual(counter, 1)
    }

    func testParsingFail() {
        let viewModel = makeSUT(id: fakeMovieID) {
            $0.api.override(route: .movie(.detail(id: fakeMovieID))) {
                try OK(
                    [
                        "deadbeaf": 0000
                    ]
                )
            }
        }

        let detail = viewModel.output.$detail.spy(&cancellabble)
        let alert = viewModel.output.alertMessage.eraseToAnyPublisher().spy(&cancellabble)
        
        viewModel.input.viewDidLoad()
        XCTAssertEqual(detail.values, [nil])
        XCTAssertEqual(alert.values, ["The data couldn’t be read because it is missing."])
    }

    func testHappyPath() {
        let viewModel = makeSUT(id: fakeMovieID) {
            $0.api.override(route: .movie(.detail(id: fakeMovieID))) {
                try OK(
                    MovieDetail.fake
                )
            }
        }

        let detail = viewModel.output.$detail.spy(&cancellabble)
        viewModel.input.viewDidLoad()
        XCTAssertEqual(detail.values.last??.originalTitle, "fake")
    }
    
}
