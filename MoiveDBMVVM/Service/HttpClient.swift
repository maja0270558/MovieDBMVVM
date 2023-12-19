//
//  HttpClient.swift
//  MoiveDBMVVM
//
//  Created by DjangoLin on 2023/12/19.
//

import Foundation

struct HttpClient {
    var request: @Sendable (Endpoint) -> (Data, URLResponse)
}
