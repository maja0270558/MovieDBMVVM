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

class MovieViewModel: ViewModelType {
    struct Input {
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

    var cancelables: Set<AnyCancellable> = .init()
    var input: Input = .init()
    var output: Output = .init()

    init(input: Input = Input()) {
        self.input = input
        bind()
    }

    func bind() {
        let api = input.viewDidLoadRelay
            .await {
                await ApiClient.current.request(serverRoute: .movie(.nowPlaying(page: 1)),
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


struct MovieList: Decodable {
    
}
