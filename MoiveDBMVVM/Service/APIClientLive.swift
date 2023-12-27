//
//  HttpClientLive.swift
//  MoiveDBMVVM
//
//  Created by DjangoLin on 2023/12/19.
//

import Foundation

extension ApiClient {
    static var current: Self = .init { api in
        do {
            return try await URLSession.shared.data(for: api.request())
        } catch {
            throw RequestError.unknown
        }
    }
}

