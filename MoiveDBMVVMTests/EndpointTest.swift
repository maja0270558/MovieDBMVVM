//
//  EndpointTest.swift
//  MoiveDBMVVMTests
//
//  Created by DjangoLin on 2023/12/26.
//

import XCTest
@testable import MoiveDBMVVM
final class EndpointTest: XCTestCase {
    
    func makeSUT(route: Endpoint) async -> (ApiClientSPY, [URLRequest]) {
        let apiClientSpy = ApiClientSPY()
        let _ = try? await apiClientSpy.request(serverRoute: route)
        return (apiClientSpy, apiClientSpy.requests)
    }
    
    func testMoviePopularEndpoint_Request_URLMatch() async {
        let (apiClientSpy, requests) = await makeSUT(route: MovieEndpoint.popular(page: 1))
        XCTAssertEqual(requests.first!.url!.absoluteString, "https://api.themoviedb.org/3/movie/popular?language=en-US&page=1")
    }
    
    func testMovieUpcommingEndpoint_Request_URLMatch() async {
        let (apiClientSpy, requests) = await makeSUT(route: MovieEndpoint.upcomming(page: 1))
        XCTAssertEqual(requests.first!.url!.absoluteString, "https://api.themoviedb.org/3/movie/upcomming?language=en-US&page=1")
    }
    
    func testMovieNowPlayingEndpoint_Request_URLMatch() async {
        let (apiClientSpy, requests) = await makeSUT(route: MovieEndpoint.nowPlaying(page: 1))
        XCTAssertEqual(requests.first!.url!.absoluteString, "https://api.themoviedb.org/3/movie/nowplaying?language=en-US&page=1")
    }
    
    func testMovieDetailEndpoint_Request_URLMatch() async {
        let (apiClientSpy, requests) = await makeSUT(route: MovieEndpoint.movieDetail(id: 1))
        XCTAssertEqual(requests.first!.url!.absoluteString, "https://api.themoviedb.org/3/movie/1?language=en-US")
    }
}
