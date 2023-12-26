//
//  HttpClient.swift
//  MoiveDBMVVM
//
//  Created by DjangoLin on 2023/12/19.
//

import Foundation

struct APIClient {
    var session: NetworrkSession
    
    func request(
        serverRoute route: Endpoint
    ) async throws -> (Data, URLResponse) {
        do {
            let urlRequest = try self.session.createRequest(route)
            let result = try await self.session.request(urlRequest)
            #if DEBUG
            print(
                """
                API: route: \(route), \
                status: \((result.1 as? HTTPURLResponse)?.statusCode ?? 0), \
                receive data: \(String(decoding: result.0, as: UTF8.self))
                """
            )
            #endif
            return result
        } catch {
            throw error
        }
    }
    
    func request<A: Decodable>(
        serverRoute route: Endpoint,
        as: A.Type
    ) async throws -> A {
        do {
            let (data, _) = try await request(serverRoute: route)
            return try apiDecode(A.self, from: data)
        } catch {
            throw error
        }
    }
}

public func apiDecode<A: Decodable>(
    _ type: A.Type,
    from data: Data
) throws -> A {
    do {
        return try decoder.decode(A.self, from: data)
    } catch let decodingError {
        throw decodingError
    }
}

let decoder: JSONDecoder = {
    let jsonDecoder = JSONDecoder()
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    jsonDecoder.dateDecodingStrategy = .formatted(formatter)
    jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
    return jsonDecoder
}()
