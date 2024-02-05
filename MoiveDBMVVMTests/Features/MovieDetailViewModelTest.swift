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
    
    func makeSUT(id: Int, _ updateValuesForOperation: (inout DependencyValues) -> Void) -> MovieDetailViewModel {
        let viewModel = withDependencies {
            updateValuesForOperation(&$0)
            $0.mainQueue = .immediate
        } operation: {
            MovieDetailViewModel(movieId: id)
        }
        return viewModel
    }

    
}
