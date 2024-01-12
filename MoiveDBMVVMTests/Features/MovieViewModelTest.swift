//
//  MovieViewModelTest.swift
//  MoiveDBMVVMTests
//
//  Created by DjangoLin on 2024/1/5.
//

import Combine
@testable import MoiveDBMVVM
import XCTest

@MainActor
final class MovieViewModelTest: XCTestCase {
    var vm = MovieViewModel()
    var cancellabble = Set<AnyCancellable>()
    override class func setUp() {
        super.setUp()
        Current.api = .noop
//        let totalPage = 3
//        for page in 1 ... totalPage {
//            Current.api.override(route: .movie(.nowPlaying(page: page))) {
//                try await OK(
//                    MovieList(
//                        page: page,
//                        results: [.mock],
//                        totalPages: totalPage,
//                        totalResults: 1
//                    )
//                )
//            }
//        }
    }

    func expect(override: (desc: String,
                           route: Api,
                           with: Encodable),
                when action: () -> Void,
                then afterFullfill: () -> Void) async
    {
        let expected = XCTestExpectation(description: override.desc)
        Current.api.override(route: override.route) {
            expected.fulfill()
            return try await OK(
                override.with
            )
        }
        action()
        await fulfillment(of: [expected], timeout: 1)
        afterFullfill()
    }

    func testMovieViewModel_loadPageCorrect() async {
        await expect(override: (desc: "Override now playing page 1",
                                route: .movie(.nowPlaying(page: 1)),
                                with: MovieList(
                                    page: 1,
                                    results: [.mock],
                                    totalPages: 3,
                                    totalResults: 1
                                ))) {
            vm.input.loadMovie(category: .nowPlaying)
        } then: {
            print(vm.output.movies.value)
            XCTAssertEqual(vm.output.movies.value.count, 1)
        }

        await expect(override: (desc: "Override now playing page 2",
                                route: .movie(.nowPlaying(page: 2)),
                                with: MovieList(
                                    page: 2,
                                    results: [.mock, .mock],
                                    totalPages: 3,
                                    totalResults: 1
                                ))) {
            vm.input.loadMovie(category: .nowPlaying)
        } then: {
            print(vm.output.movies.value)
            XCTAssertEqual(vm.output.movies.value.count, 2)
        }
    }

    func testMovieViewModel_initLoad_pageShouldEqualToOne() async throws {
        let spyValue = vm.output.movies.spy(&cancellabble)

        Current.api.override(route: .movie(.nowPlaying(page: 1))) {
            Just(
                try OK(
                    MovieList(
                    page: 1,
                    results: [.mock],
                    totalPages: 1,
                    totalResults: 1
                )
                )
            )
            .setFailureType(to: URLError.self)
            .eraseToAnyPublisher()
        }

        vm.input.loadMovie(category: .nowPlaying)
        print(spyValue.values)

        Current.api.override(route: .movie(.nowPlaying(page: 2))) {
            Just(
                try OK(
                    MovieList(
                    page: 1,
                    results: [.mock],
                    totalPages: 1,
                    totalResults: 1
                )
                )
            )
            .setFailureType(to: URLError.self)
            .eraseToAnyPublisher()
        }
        vm.input.loadMovie(category: .nowPlaying)
        
        let page = await vm.fetchData.currentPage(.nowPlaying)
        print(spyValue.values)
    }
}
