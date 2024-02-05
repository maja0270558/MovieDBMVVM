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
        var alertMessage: PassthroughSubject<String, Never> = .init()
    }
}

class MovieDetailViewModel: ViewModelType {
    @Dependency(\.api) var api
    @Dependency(\.mainQueue) var queue
    @Dependency(\.reachability) var reachability

    var input: Input = .init()
    var output: Output = .init()
    var fetchMovieId: Int
    
    private(set) var cancellables: Set<AnyCancellable> = .init()
    private(set) var requestCancellable: AnyCancellable?
    private(set) var isConnected: Bool = true

    init(movieId: Int) {
        self.fetchMovieId = movieId
        bind()
    }
    
    func bind() {
        reachability.pathUpdatePublisher.eraseToAnyPublisher()
            .removeDuplicates()
            .sink(receiveValue: { [weak self] path in
                guard let self = self else { return }
                self.isConnected = path.status == .satisfied
            })
            .store(in: &cancellables)
        
        input.viewDidLoadSubject
            .eraseToAnyPublisher()
            .filter { [unowned self] _ in
                guard self.isConnected else {
                    self.output.alertMessage.send("The internet is down :[")
                    return false
                }
                return true
            }
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
                self.output.alertMessage.send(error.localizedDescription)
                return
            }

            if let success = result.success {
                self.output.detail = success
            }
        }
    }
    
}
