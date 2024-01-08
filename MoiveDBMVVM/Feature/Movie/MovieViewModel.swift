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
        fileprivate var viewDidLoadRelay: PassthroughSubject<Void, Never> = .init()
        public func viewDidLoad() {
            viewDidLoadRelay.send(())
        }

        fileprivate var reloadRelay: PassthroughSubject<Void, Never> = .init()
        public func reload() {
            reloadRelay.send(())
        }

        fileprivate var loadNextPageRelay: PassthroughSubject<Void, Never> = .init()
        public func loadNextPage() {
            loadNextPageRelay.send(())
        }
    }

    struct Output {
        var movies: CurrentValueSubject<[MovieList.Movie], Never> = .init([])
        var alertMessage: AnyPublisher<String, Never>?
    }
}

class MovieViewModel {
    private(set) var currentPage = 0
    private(set) var totalPage = 0

    var cancellables: Set<AnyCancellable> = .init()
    var input: Input = .init()
    var output: Output = .init()

    init(input: Input = Input()) {
        self.input = input
        bind()
    }

    func bind() {
        let reload = input.reloadRelay.map { [unowned self] _ in
            self.currentPage = 1
            return self.currentPage
        }

        let nextPage = input.viewDidLoadRelay
            .combineLatest(input.loadNextPageRelay)
            .map { [unowned self] _ in
                self.currentPage += 1
                return self.currentPage
            }

        let fetchTrigger = reload.merge(with: nextPage)

        let api = fetchTrigger
            .await { page in
                await Envirment.current.api.request(serverRoute: .movie(.nowPlaying(page: page)),
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
