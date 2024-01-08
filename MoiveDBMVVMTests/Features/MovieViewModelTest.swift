//
//  MovieViewModelTest.swift
//  MoiveDBMVVMTests
//
//  Created by DjangoLin on 2024/1/5.
//

@testable import MoiveDBMVVM
import XCTest

final class MovieViewModelTest: XCTestCase {

    func testMovieViewModel_initLoad_pageShouldEqualToOne() {
        let vm = MovieViewModel()
        vm.input.viewDidLoad()
        XCTAssertEqual(vm.currentPage, 1)
    }
    
    func testMovieViewModel_nextPage_pageShouldEqualToOne() {
        let vm = MovieViewModel()
        vm.input.viewDidLoad()
        
        vm.input.loadNextPage()
        XCTAssertEqual(vm.currentPage, 2)
    }
    
    func testMovieViewModel_reloadAfterNextPage_pageShouldEqualToOne() {
        let vm = MovieViewModel()
        vm.input.viewDidLoad()
        
        vm.input.loadNextPage()
        XCTAssertEqual(vm.currentPage, 2)

        vm.input.reload()
        XCTAssertEqual(vm.currentPage, 1)
    }
}
