//
//  MovieViewModel.swift
//  MoiveDBMVVM
//
//  Created by DjangoLin on 2024/1/2.
//

import Combine
import Foundation
import Dependencies

extension MovieViewModel: ViewModelType {
    struct Input {
        enum MovieLoadType {
            case reload
            case loadNext
        }
        
        fileprivate var loadMovieRelay: PassthroughSubject<MovieLoadType, Never> = .init()
        func loadMovie() {
            loadMovieRelay.send(.loadNext)
        }

        public func reload() {
            loadMovieRelay.send(.reload)
        }
    }
    
    struct Output {
        var movies: CurrentValueSubject<[MovieCellViewModel], Never> = .init([])
        var alertMessage: PassthroughSubject<String, Never> = .init()
        var isLoading: CurrentValueSubject<Bool, Never> = .init(false)
    }
}

class MovieViewModel {
    @Dependency(\.mainQueue) var queue
    @Dependency(\.api) var api
    @Dependency(\.reachability) var reachability
    @Dependency(\.test) var testString

    var state = MovieViewModelState()
    var input: Input = .init()
    var output: Output = .init()
    
    var isConnected: Bool = true
    var cancellables: Set<AnyCancellable>
    var requestCancellable: AnyCancellable?

    init(input: Input = Input(), cancellables: Set<AnyCancellable> = .init()) {
        self.cancellables = cancellables
        self.input = input
        bind()
    }

    fileprivate func bind() {
      input.loadMovieRelay
            .handleOutput { [weak self] in
                guard let self = self else { return }
                if $0 == .reload {
                    self.output.movies.send([])
                    self.state.reset()
                }
            }
            .filter { [unowned self] _ in self.state.needToLoadMore() }
            .sink(receiveValue: { [unowned self] _ in
                /// cancel on flight fetch
                self.requestCancellable?.cancel()
                self.requestCancellable = nil
                /// fetch movie
                self.requestCancellable = self.fetchMovies()
            })
            .store(in: &cancellables)
          
        
        /// Network
        reachability.pathUpdatePublisher.eraseToAnyPublisher()
            .removeDuplicates()
            .sink(receiveValue: { [weak self] path in
                guard let self = self else { return }
                self.isConnected = path.status == .satisfied
            })
            .store(in: &cancellables)
    }
    
    fileprivate func fetchMovies() -> AnyCancellable {
        output.isLoading.send(true)
        return api.request(
            serverRoute: .movie(
                .nowPlaying(
                    page: self.state.currentPage + 1
                )
            ),
            as: MovieList.self
        )
        .receive(on: queue)
        .sink { [weak self] result in
            guard let self = self else { return }
            self.output.isLoading.send(false)
            
            if let error = result.failure {
                self.output.alertMessage.send(error.localizedDescription)
                return
            }
            
            if let success = result.success {
                self.state.setPage(current: success.page, success.totalPages)
                var results = self.output.movies.value
                let cellViewModels = success.results.compactMap  {
                    return MovieCellViewModel(title: $0.title ?? "",
                                              image: $0.posterPath ?? "",
                                              overview: $0.overview)
                }
                results.append(contentsOf: cellViewModels)
                self.output.movies.send(results)
            }
        }
    }
}

struct MovieViewModelState {
    private(set) var currentPage = 0
    private(set) var totalPage: Int?

    func needToLoadMore() -> Bool {
        guard let totalPage = totalPage
        else {
            return true
        }
        return totalPage > currentPage
    }

    mutating func reset() {
        currentPage = 0
        totalPage = nil
    }

    mutating func setPage(current: Int, _ page: Int?) {
        currentPage = current
        totalPage = page
    }
}
