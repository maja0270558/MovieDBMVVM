//
//  MovieViewModel.swift
//  MoiveDBMVVM
//
//  Created by DjangoLin on 2024/1/2.
//

import Combine
import Foundation

extension MovieViewModel: ViewModelType {
    struct Input {
        fileprivate var loadMovieRelay: PassthroughSubject<Void, Never> = .init()
        func loadMovie() {
            loadMovieRelay.send(())
        }

        fileprivate var reloadRelay: PassthroughSubject<Void, Never> = .init()
        public func reload() {
            reloadRelay.send(())
        }
    }

    struct Output {
        var movies: CurrentValueSubject<[MovieList.Movie], Never> = .init([])
        var alertMessage: AnyPublisher<String, Never>?
    }
}

// TODO: manage data
// TODO: what output will look  like

class MovieViewModel {
    var state = MovieViewModelState()
    var cancellables: Set<AnyCancellable>
    var input: Input = .init()
    var output: Output = .init()
    
    deinit {
        print("Deinit object")
    }

    init(input: Input = Input(), cancellables: Set<AnyCancellable> = .init()) {
        self.cancellables = cancellables
        self.input = input
        bind()
    }

    func bind() {
        let reload = input.reloadRelay
            .handleOutput { [unowned self] in
                self.state.reset()
            }
            .share()

        let loadMovie = input.loadMovieRelay
            .filter { [unowned self] in
                return self.state.needToLoadMore()
            }
            .handleOutput { [unowned self] _ in
                self.state.increesePage()
            }
            .share()

        let api = Publishers.Merge(reload, loadMovie)
            .flatMap { [unowned self] _ in
                Current.api.request(
                    serverRoute: .movie(
                        .nowPlaying(
                            page: self.state.currentPage
                        )
                    ),
                    as: MovieList.self
                )
            }
            .eraseToAnyPublisher()
            .share()

        api.compactMap { $0.success }
            .handleOutput { [unowned self] value in
                self.state.setTotalPage(value.totalPages)
            }
            .map { $0.results }
            .sink(receiveValue: { [unowned self] movies in
                var output: [MovieList.Movie] = self.output.movies.value
                output.append(contentsOf: movies)
                self.output.movies.send(movies)
            })
            .store(in: &cancellables)

        output.alertMessage = api.compactMap { $0.failure }
            .map { $0.localizedDescription }
            .eraseToAnyPublisher()
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
        currentPage = 1
        totalPage = nil
    }

    mutating func increesePage() {
        currentPage += 1
    }

    mutating func setTotalPage(_ page: Int?) {
        totalPage = page
    }
}
