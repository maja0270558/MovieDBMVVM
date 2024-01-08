//
//  MovieViewModel.swift
//  MoiveDBMVVM
//
//  Created by DjangoLin on 2024/1/2.
//

import Combine
import Foundation

protocol ViewModelType {
    associatedtype Input
    associatedtype Output

    var input: Input { get }
    var output: Output { get }
}

extension MovieViewModel: ViewModelType {
    struct Input {
        fileprivate var loadMovieRelay: PassthroughSubject<MovieListCategory, Never> = .init()
        func loadMovie(category: MovieListCategory) {
            loadMovieRelay.send(category)
        }
        
        fileprivate var reloadRelay: PassthroughSubject<MovieListCategory, Never> = .init()
        public func reload(category: MovieListCategory) {
            reloadRelay.send(category)
        }
    }

    struct Output {
        var movies: CurrentValueSubject<[MovieList.Movie], Never> = .init([])
        var alertMessage: AnyPublisher<String, Never>?
    }
}



struct FetchParameter {
    var currentPage = 1
    var totalPage = Int.max
}

class MovieViewModel {
    var fetchParameter: [MovieListCategory: FetchParameter] = [:]
    var cancellables: Set<AnyCancellable> = .init()
    var input: Input = .init()
    var output: Output = .init()

    init(input: Input = Input()) {
        self.input = input
        bind()
    }

    func bind() {
        let reload = input.reloadRelay.map { [unowned self] type in
            self.fetchParameter[type] = .init()
            return type
        }

        let loadMovieFromCategory = input.loadMovieRelay
            .map { [unowned self] type in
                let parameter = self.fetchParameter[type, default: .init()]
                self.fetchParameter[type] = .init(currentPage: parameter.currentPage + 1)
                return type
            }

        let fetchTrigger = reload.merge(with: loadMovieFromCategory)

        let api = fetchTrigger
            .await { [unowned self] type in
                let page = self.fetchParameter[type]?.currentPage ?? 1
                let route: Api
                switch type {
                case .nowPlaying:
                    route = .movie(.nowPlaying(page: page))
                case .popular:
                    route = .movie(.popular(page: page))
                case .upcomming:
                    route = .movie(.upcoming(page: page))

                }
                return await Envirment.current.api.request(serverRoute: route,
                                                           as: MovieList.self)
            }
            .share()

        api.compactMap { $0.success }
            .map { $0.results }
            .assign(to: \.value, on: output.movies)
            .store(in: &cancellables)

        output.alertMessage = api.compactMap { $0.failure }
            .map { $0.localizedDescription }
            .eraseToAnyPublisher()
    }
}
