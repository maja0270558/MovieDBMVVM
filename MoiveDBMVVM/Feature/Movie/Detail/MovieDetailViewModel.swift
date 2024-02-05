//
//  MovieDetailViewModel.swift
//  MoiveDBMVVM
//
//  Created by DjangoLin on 2024/1/30.
//

import Foundation
import Combine
import Dependencies

extension MovieDetailViewModel {
    struct Input {
        fileprivate var viewDidLoadSubject: PassthroughSubject<Void, Never> = .init()
        public func viewDidLoad() {
            viewDidLoadSubject.send(())
        }
    }
    
    class Output {
        @Published var detail: MovieDetail?
    }
}

class MovieDetailViewModel: ViewModelType {
    @Dependency(\.api) var api
    @Dependency(\.mainQueue) var queue

    var input: Input = .init()
    var output: Output = .init()
    var fetchMovieId: Int
    
    private(set) var cancellables: Set<AnyCancellable> = .init()
    private(set) var requestCancellable: AnyCancellable?
    
    init(movieId: Int) {
        self.fetchMovieId = movieId
        bind()
    }
    
    func bind() {
        input.viewDidLoadSubject
            .eraseToAnyPublisher()
            .sink { [weak self] in
                guard let self = self else { return }
                self.requestCancellable = self.fetchDetail()
            }
            .store(in: &cancellables)
    }
    
    
    fileprivate func fetchDetail() -> AnyCancellable {
        return api.request(
            serverRoute: .movie(
                .detail(id: fetchMovieId)
            ),
            as: MovieDetail.self
        )
        .receive(on: queue)
        .sink { [weak self] result in
            guard let self = self else { return }

            if let error = result.failure {
                print(error)
                return
            }

            if let success = result.success {
                self.output.detail = success
            }
        }
    }
    
}
