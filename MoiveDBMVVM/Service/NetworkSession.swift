//
//  NetworkSession.swift
//  MoiveDBMVVM
//
//  Created by DjangoLin on 2023/12/26.
//

//import Foundation
//
//struct NetworrkSession {
//    var request: @Sendable (URLRequest) async throws -> (data: Data, response: URLResponse)
//    var createRequest: @Sendable (Endpoint) throws -> URLRequest
//}
//
//extension NetworrkSession {
//    static let live: Self = .init(
//        request: { request in
//            do {
//                return try await URLSession.shared.data(for: request)
//            } catch {
//                throw RequestError.unknown
//            }
//        },
//        createRequest: {
//            try $0.request()
//        }
//    )
//}
//
