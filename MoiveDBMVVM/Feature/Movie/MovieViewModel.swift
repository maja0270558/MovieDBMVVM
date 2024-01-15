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
        fileprivate var loadMovieRelay: PassthroughSubject<MovieListCategory, Never> = .init()
        func loadMovie(category: MovieListCategory) {
            loadMovieRelay.send(category)
        }

        fileprivate var reloadRelay: PassthroughSubject<MovieListCategory, Never> = .init()
        public func reload(category: MovieListCategory) {
            reloadRelay.send(category)
        }

        fileprivate var switchSegementRelay: PassthroughSubject<MovieListCategory, Never> = .init()
        public func switchSegement(category: MovieListCategory) {
            switchSegementRelay.send(category)
        }
    }

    struct Output {
        var movies: CurrentValueSubject<[MovieList.Movie], Never> = .init([])
        var alertMessage: AnyPublisher<String, Never>?
    }
}

@MainActor
class MovieViewModel {
    var state = MovieListFetchData()
    var cancellables: Set<AnyCancellable>
    var input: Input = .init()
    var output: Output = .init()

    init(input: Input = Input(), cancellables: Set<AnyCancellable> = .init()) {
        self.cancellables = cancellables
        self.input = input
        bind()
    }

    func bind() {
        let segmentChangeAndLoad = input.switchSegementRelay.eraseToAnyPublisher()
            .filter { cate in
                !self.state.exist(cate)
            }

        let changeDataSource = input.switchSegementRelay.eraseToAnyPublisher()
            .filter { cate in
                self.state.exist(cate)
            }

        let reload = Publishers.Merge(segmentChangeAndLoad, input.reloadRelay)
            .handleOutput { [unowned self] cate in
                self.state.reset(cate)
            }

        let loadMovieFromCategory = input.loadMovieRelay
            .filter { cate in
                self.state.checkValidPage(cate)
            }
            .handleOutput { [weak self] cate in
                self?.state.increesePage(cate)
            }

        let api = Publishers.Merge(reload, loadMovieFromCategory)
            .map { [unowned self] cate in
                let page =  self.state.currentPage(cate)
                return cate.api(page: page)
            }
            .flatMap { route in
                Current.api.request(serverRoute: route,
                                    as: MovieList.self)
            }
            .eraseToAnyPublisher()
            .share()

        api.compactMap { $0.success }
            .handleOutput { [weak self] value in
                self?.state.setTotalPage(value.totalPages, to: .upcomming)
            }
            .map { $0.results }
            .assign(to: \.value, on: output.movies)
            .store(in: &cancellables)

        output.alertMessage = api.compactMap { $0.failure }
            .map { $0.localizedDescription }
            .eraseToAnyPublisher()
    }
}

struct MovieListFetchData {
    struct FetchParameter {
        var currentPage = 0
        var totalPage: Int?
    }

    private(set) var fetchParameter: [MovieListCategory: FetchParameter] = [:]

    func exist(_ cate: MovieListCategory) -> Bool {
        return fetchParameter[cate] != nil
    }

    func currentPage(_ cate: MovieListCategory) -> Int {
        return fetchParameter[cate]?.currentPage ?? 1
    }

    func checkValidPage(_ cate: MovieListCategory) -> Bool {
        guard let totalPage = fetchParameter[cate]?.totalPage,
              let currentPage = fetchParameter[cate]?.currentPage
        else {
            return true
        }
        return totalPage > currentPage
    }

    mutating func reset(_ cate: MovieListCategory) {
        fetchParameter[cate] = .init(currentPage: 1)
    }

    mutating func increesePage(_ cate: MovieListCategory) {
        let parameter = fetchParameter[cate, default: .init()]
        fetchParameter[cate] = .init(currentPage: parameter.currentPage + 1, totalPage: parameter.totalPage)
    }

    mutating func setTotalPage(_ page: Int?, to: MovieListCategory) {
        fetchParameter[to]?.totalPage = page
    }
}
