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
        var currentPage: Int = 1
        fileprivate var viewDidLoadRelay: PassthroughSubject<Void, Never> = .init()
        public func viewDidLoad() {
            viewDidLoadRelay.send(())
        }

        fileprivate var reloadRelay: PassthroughSubject<Void, Never> = .init()
        public func reload() {
            reloadRelay.send(())
        }
    }

    struct Output {
        var movies: CurrentValueSubject<MovieList?, Never> = .init(nil)
        var alertMessage: AnyPublisher<String, Never>?
    }
}

class MovieViewModel {
    var cancelables: Set<AnyCancellable> = .init()
    var input: Input = .init()
    var output: Output = .init()

    init(input: Input = Input()) {
        self.input = input
        bind()
    }

    func bind() {
        let api = input.viewDidLoadRelay
            .await { [unowned self] _ in
                await ApiClient.current.request(serverRoute: .movie(.nowPlaying(page: self.input.currentPage)),
                                                as: MovieList.self)
            }
            .share()

        api.compactMap { $0.success }
            .assign(to: \.value, on: output.movies)
            .store(in: &cancelables)

        output.alertMessage = api.compactMap { $0.failure }
            .map { $0.localizedDescription }
            .eraseToAnyPublisher()
    }
}
