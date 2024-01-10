//
//  MovieViewModel.swift
//  MoiveDBMVVM
//
//  Created by DjangoLin on 2024/1/2.
//

import Combine
import Foundation

extension Publisher {
    func handleOutput(_ receiveOutput: @escaping ((Self.Output) -> Void)) -> Publishers.HandleEvents<Self> {
        handleEvents(receiveOutput: receiveOutput)
    }

    func handleError(_ receiveError: @escaping ((Self.Failure) -> Void)) -> Publishers.HandleEvents<Self> {
        handleEvents(receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
                receiveError(error)
            case .finished:
                ()
            }
        })
    }
}

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
    var fetchData = MovieListFetchData()
    var cancellables: Set<AnyCancellable> = .init()
    var input: Input = .init()
    var output: Output = .init()

    init(input: Input = Input()) {
        self.input = input
        bind()
    }

    func bind() {
        
        let segmentChangeAndLoad = input.switchSegementRelay.eraseToAnyPublisher()
            .awaitFilter { cate in
                return await !self.fetchData.exist(cate)
            }
            
        
        let changeDataSource = input.switchSegementRelay.eraseToAnyPublisher()
            .awaitFilter { cate in
                return await self.fetchData.exist(cate)
            }
            
        
        let reload = Publishers.Merge(segmentChangeAndLoad, input.reloadRelay)
            .handleOutput {  [unowned self] cate in
                Task {
                    await self.fetchData.reset(cate)
                }
            }
           

        let loadMovieFromCategory = input.loadMovieRelay
            .awaitFilter { cate in
                return await self.fetchData.checkValidPage(cate)
            }
            .handleOutput { [weak self] cate in
                Task {
                    await self?.fetchData.increesePage(cate)
                }
            }
        
        
        let api = Publishers.Merge(reload, loadMovieFromCategory)
            .await { [unowned self] cate in
                let page = await self.fetchData.currentPage(cate)
                let route: Api = self.convertMovieCategoryToApi(category: cate, page: page)
                let result = await Current.api.request(serverRoute: route,
                                                                 as: MovieList.self)
                return result
            }
            .share()
        
        api.compactMap { $0.success }
            .handleOutput { [weak self] value in
                Task {
                    await self?.fetchData.setTotalPage(value.totalPages, to: .upcomming)
                }
            }
            .map { $0.results }
            .assign(to: \.value, on: output.movies)
            .store(in: &cancellables)

        output.alertMessage = api.compactMap { $0.failure }
            .map { $0.localizedDescription }
            .eraseToAnyPublisher()
    }
    
    fileprivate func convertMovieCategoryToApi(category: MovieListCategory, page: Int) -> Api {
        switch category {
        case .nowPlaying:
           return .movie(.nowPlaying(page: page))
        case .popular:
           return .movie(.popular(page: page))
        case .upcomming:
           return .movie(.upcoming(page: page))
        }
    }
}

actor MovieListFetchData {
    
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
              let currentPage = fetchParameter[cate]?.currentPage else {
            return true
        }
        return totalPage > currentPage
    }
    
     func reset(_ cate: MovieListCategory) {
        fetchParameter[cate] = .init(currentPage: 1)
    }
    
     func increesePage(_ cate: MovieListCategory) {
        let parameter = fetchParameter[cate, default: .init()]
        fetchParameter[cate] = .init(currentPage: parameter.currentPage + 1)
    }
    
     func setTotalPage(_ page: Int?, to: MovieListCategory) {
        fetchParameter[to]?.totalPage = page
    }
}
