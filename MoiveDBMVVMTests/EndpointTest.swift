//
//  EndpointTest.swift
//  MoiveDBMVVMTests
//
//  Created by DjangoLin on 2023/12/26.
//

@testable import MoiveDBMVVM
import XCTest

final class EndpointTest: XCTestCase {
    func expect(api: Api, equalTo to: String) {
        let request = try? api.request()
        XCTAssertEqual(request?.url?.absoluteString, to)
    }

    func testMoviePopularEndpoint_URLMatch() async {
        expect(
            api: .movie(.popular(page: 1)),
            equalTo: "https://api.themoviedb.org/3/movie/popular?language=en-US&page=1"
        )

        expect(
            api: .movie(.popular(page: 2)),
            equalTo: "https://api.themoviedb.org/3/movie/popular?language=en-US&page=2"
        )
    }

    func testMovieUpcommingEndpoint_URLMatch() async {
        expect(
            api: .movie(.upcomming(page: 1)),
            equalTo: "https://api.themoviedb.org/3/movie/upcomming?language=en-US&page=1"
        )
        expect(
            api: .movie(.upcomming(page: 2)),
            equalTo: "https://api.themoviedb.org/3/movie/upcomming?language=en-US&page=2"
        )
    }

    func testMovieNowPlayingEndpoint_URLMatch() async {
        expect(
            api: .movie(.nowPlaying(page: 1)),
            equalTo: "https://api.themoviedb.org/3/movie/nowplaying?language=en-US&page=1"
        )
        expect(
            api: .movie(.nowPlaying(page: 2)),
            equalTo: "https://api.themoviedb.org/3/movie/nowplaying?language=en-US&page=2"
        )
    }

    func testMovieDetailEndpoint_URLMatch() async {
        expect(
            api: .movie(.detail(id: 1)),
            equalTo: "https://api.themoviedb.org/3/movie/1?language=en-US"
        )
    }
}
