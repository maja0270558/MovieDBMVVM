//
//  Envirment.swift
//  MoiveDBMVVM
//
//  Created by DjangoLin on 2024/1/8.
//

import Foundation
import Dependencies

private enum ApiClientKey: DependencyKey {
    static var liveValue: ApiClient = .live
    static var testValue: ApiClient = .noop
}

private enum ImageFetcherKey: DependencyKey {
    static let liveValue: ImageFetcherClient = .live
    static var testValue: ImageFetcherClient = .fake
}

private enum ReachabilityClientKey: DependencyKey {
    static let liveValue: ReachabilityClient = .live(.main)
    static var testValue: ReachabilityClient = .satisfied
}

public extension DependencyValues {
    var api: ApiClient {
        get { self[ApiClientKey.self] }
        set { self[ApiClientKey.self] = newValue }
    }

    var imageFetcher: ImageFetcherClient {
        get { self[ImageFetcherKey.self] }
        set { self[ImageFetcherKey.self] = newValue }
    }
    
    var reachability: ReachabilityClient {
        get { self[ReachabilityClientKey.self] }
        set { self[ReachabilityClientKey.self] = newValue }
    }
}

