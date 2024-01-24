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
    static let liveValue: ImageFetcher = .live
    static var testValue: ImageFetcher = .mock
}

private enum ReachabilityClientKey: DependencyKey {
    static let liveValue: ReachabilityClient = .live(.main)
    static var testValue: ReachabilityClient = .satisfied
}

private enum TestKey: DependencyKey {
    static let liveValue = "Live"
    static var testValue: String = "Test"
}

public extension DependencyValues {
    var api: ApiClient {
        get { self[ApiClientKey.self] }
        set { self[ApiClientKey.self] = newValue }
    }

    var imageFetcher: ImageFetcher {
        get { self[ImageFetcherKey.self] }
        set { self[ImageFetcherKey.self] = newValue }
    }
    
    var reachability: ReachabilityClient {
        get { self[ReachabilityClientKey.self] }
        set { self[ReachabilityClientKey.self] = newValue }
    }
    
    var test: String {
        get { self[TestKey.self] }
        set { self[TestKey.self] = newValue }
    }
}
