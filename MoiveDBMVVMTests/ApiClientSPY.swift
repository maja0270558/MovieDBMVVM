////
////  MovieListClientTest.swift
////  MoiveDBMVVMTests
////
////  Created by DjangoLin on 2023/12/19.
////
//
//@testable import MoiveDBMVVM
//import XCTest
//
//class ApiClientSPY {
//    var requests: [URLRequest] = []
//
//    func request<A>(
//        serverRoute route: MoiveDBMVVM.Endpoint,
//        response: () -> A = { return "deadbeef" }
//    ) async throws -> A where A: Decodable {
//        let session = NetworrkSession.stub { [weak self] request in
//            self?.requests.append(request)
//        }
//        let client: APIClient = .init(session: session)
//        let _ = try await client.request(serverRoute: route)
//        return response()
//    }
//}
//
//extension NetworrkSession {
//    static func stub(monitor: @escaping (URLRequest) -> Void) -> NetworrkSession {
//        return .init(request: {
//                         monitor($0)
//                         return (Data(), URLResponse())
//                     },
//                     createRequest: { try $0.request() })
//    }
//}
