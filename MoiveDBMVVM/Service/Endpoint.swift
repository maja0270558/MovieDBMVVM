//
//  Endpoint.swift
//  MoiveDBMVVM
//
//  Created by DjangoLin on 2023/12/19.
//

import Foundation
enum RequestMethod: String {
    case DELETE
    case GET
    case PATCH
    case POST
    case PUT
}

protocol Endpoint: Equatable {
    var scheme: String { get }
    var host: String { get }
    var path: String { get }
    var method: RequestMethod { get }
    var header: [String: String]? { get }
    var body: [String: String]? { get }
    var query: [URLQueryItem]? { get }
}

extension Endpoint {
    var scheme: String { return "https" }
    var host: String { return "/api.themoviedb.org/3/" }
    var query: [URLQueryItem]? { return [] }
}
