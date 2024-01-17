//
//  RequestError.swift
//  MoiveDBMVVM
//
//  Created by DjangoLin on 2023/12/19.
//

import Foundation

public enum RequestError: LocalizedError {
    case decode(message: String)
    case invalidURL
    case noResponse
    case unexpectedStatusCode
    case unknown
}
