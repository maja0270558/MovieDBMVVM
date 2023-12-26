//
//  EndpointTest.swift
//  MoiveDBMVVMTests
//
//  Created by DjangoLin on 2023/12/26.
//

import XCTest
@testable import MoiveDBMVVM
final class EndpointTest: XCTestCase {
    lazy var client = makeSUT()
    
    func makeSUT() -> ApiClientSPY {
        let apiClientSpy = ApiClientSPY()
        return apiClientSpy
    }
    
    override func tearDown() async throws {
        client.requests.removeAll()
    }
    
    private func fireRequest(_ sererRoute: Endpoint) async {
        let _ = try? await client.request(serverRoute: sererRoute)
    }
    
    func testMoviePopularEndpoint_Request_URLMatch() async {
        await fireRequest(MovieEndpoint.popular(page: 1))
        XCTAssertEqual(client.requests[0].url!.absoluteString, "https://api.themoviedb.org/3/movie/popular?language=en-US&page=1")
        await fireRequest(MovieEndpoint.popular(page: 2))
        XCTAssertEqual(client.requests[1].url!.absoluteString, "https://api.themoviedb.org/3/movie/popular?language=en-US&page=2")
    }
    
    func testMovieUpcommingEndpoint_Request_URLMatch() async {
        await fireRequest(MovieEndpoint.upcomming(page: 1))
        XCTAssertEqual(client.requests[0].url!.absoluteString, "https://api.themoviedb.org/3/movie/upcomming?language=en-US&page=1")
        await fireRequest(MovieEndpoint.upcomming(page: 2))
        XCTAssertEqual(client.requests[1].url!.absoluteString, "https://api.themoviedb.org/3/movie/upcomming?language=en-US&page=2")
    }
    
    func testMovieNowPlayingEndpoint_Request_URLMatch() async {
        await fireRequest(MovieEndpoint.nowPlaying(page: 1))
        XCTAssertEqual(client.requests[0].url!.absoluteString, "https://api.themoviedb.org/3/movie/nowplaying?language=en-US&page=1")
        await fireRequest(MovieEndpoint.nowPlaying(page: 2))
        XCTAssertEqual(client.requests[1].url!.absoluteString, "https://api.themoviedb.org/3/movie/nowplaying?language=en-US&page=2")
    }
    
    func testMovieDetailEndpoint_Request_URLMatch() async {
        let _ = try? await client.request(serverRoute: MovieEndpoint.movieDetail(id: 1))
        XCTAssertEqual(client.requests.first!.url!.absoluteString, "https://api.themoviedb.org/3/movie/1?language=en-US")
    }
}
