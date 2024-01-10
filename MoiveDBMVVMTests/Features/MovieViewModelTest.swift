//
//  MovieViewModelTest.swift
//  MoiveDBMVVMTests
//
//  Created by DjangoLin on 2024/1/5.
//

@testable import MoiveDBMVVM
import XCTest
import Combine

extension XCTestCase {
    func awaitPublisher<T: Publisher>(
        _ publisher: T,
        timeout: TimeInterval = 10,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> T.Output {
        // This time, we use Swift's Result type to keep track
        // of the result of our Combine pipeline:
        var result: Result<T.Output, Error>?
        let expectation = self.expectation(description: "Awaiting publisher")

        let cancellable = publisher.sink(
            receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    result = .failure(error)
                case .finished:
                    break
                }

                expectation.fulfill()
            },
            receiveValue: { value in
                result = .success(value)
            }
        )

        // Just like before, we await the expectation that we
        // created at the top of our test, and once done, we
        // also cancel our cancellable to avoid getting any
        // unused variable warnings:
        waitForExpectations(timeout: timeout)
        cancellable.cancel()

        // Here we pass the original file and line number that
        // our utility was called at, to tell XCTest to report
        // any encountered errors at that original call site:
        let unwrappedResult = try XCTUnwrap(
            result,
            "Awaited publisher did not produce any output",
            file: file,
            line: line
        )

        return try unwrappedResult.get()
    }
}

extension Published.Publisher {
    func collectNext(_ count: Int) -> AnyPublisher<[Output], Never> {
        self.dropFirst()
            .collect(count)
            .first()
            .eraseToAnyPublisher()
    }
}

extension PassthroughSubject {
    func collectNext(_ count: Int) -> AnyPublisher<[Output], Failure> {
        self.collect(count)
            .first()
            .eraseToAnyPublisher()
    }
}

extension AnyPublisher {
    func collectNext(_ count: Int) -> AnyPublisher<[Output], Failure> {
        self.collect(count)
            .first()
            .eraseToAnyPublisher()
    }
}


extension CurrentValueSubject {
    func collectNext(_ count: Int) -> AnyPublisher<[Output], Failure> {
        self.dropFirst()
            .collect(count)
            .first()
            .eraseToAnyPublisher()
    }
}

@MainActor
final class MovieViewModelTest: XCTestCase {
    var vm = MovieViewModel()

    override class func setUp() {
        super.setUp()
        Current.api = .noop
        Current.api.override(route: .movie(.nowPlaying(page: 1))) {
            try await OK([])
        }
        Current.api.override(route: .movie(.nowPlaying(page: 2))) {
            try await OK([])
        }
        Current.api.override(route: .movie(.nowPlaying(page: 3))) {
            try await OK([])
        }

    }
    
    func testMovieViewModel_initLoad_pageShouldEqualToOne() throws {

//        let moviePublisher = vm.output.movies.collectNext(1)
        let alertPublisher = vm.output.alertMessage?.collectNext(3)

        vm.input.loadMovie(category: .nowPlaying)
        vm.input.loadMovie(category: .nowPlaying)
        vm.input.loadMovie(category: .nowPlaying)

//        let movie = try awaitPublisher(moviePublisher)
        let alert = try awaitPublisher(alertPublisher!)

        print(alert)
//        XCTAssertEqual(movie.first!.count, 20)
    }
//    
//    func testMovieViewModel_nextPage_pageShouldEqualToOne()  {
//        Current.api = .noop
//        Current.aTestString = "test 😀"
//
//        vm.input.loadMovie(category: .nowPlaying)
//        XCTAssertEqual(vm.fetchData.currentPage(.nowPlaying), 1)
//        
//        vm.input.loadMovie(category: .nowPlaying)
//        XCTAssertEqual(vm.fetchData.currentPage(.nowPlaying), 2)
//    }
//    
//    func testMovieViewModel_reloadAfterNextPage_pageShouldEqualToOne()  {
//        Current.api = .noop
//        Current.aTestString = "test 😀"
//
//        vm.input.loadMovie(category: .nowPlaying)
//        XCTAssertEqual(vm.fetchData.currentPage(.nowPlaying), 1)
//        
//        vm.input.loadMovie(category: .nowPlaying)
//        XCTAssertEqual(vm.fetchData.currentPage(.nowPlaying), 2)
//        
//        vm.input.reload(category: .nowPlaying)
//        XCTAssertEqual(vm.fetchData.currentPage(.nowPlaying), 1)
//    }
}
