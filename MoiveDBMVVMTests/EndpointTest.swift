//
//  EndpointTest.swift
//  MoiveDBMVVMTests
//
//  Created by DjangoLin on 2023/12/26.
//

@testable import MoiveDBMVVM
import XCTest

final class EndpointTest: XCTestCase {
    func expect(api: ApiRoute, equalTo to: String) {
        let request = try? api.request()
        XCTAssertEqual(request?.url?.absoluteString, to)
    }

    func testMovieNowPlayingEndpointURLMatch() async {
        expect(
            api: .movie(.nowPlaying(page: 1)),
            equalTo: "https://api.themoviedb.org/3/movie/now_playing?language=en-US&page=1"
        )
        expect(
            api: .movie(.nowPlaying(page: 2)),
            equalTo: "https://api.themoviedb.org/3/movie/now_playing?language=en-US&page=2"
        )
    }

    func testMovieDetailEndpointURLMatch() async {
        expect(
            api: .movie(.detail(id: 1)),
            equalTo: "https://api.themoviedb.org/3/movie/1?language=en-US"
        )
    }
}
