//
//  Envirment.swift
//  MoiveDBMVVM
//
//  Created by DjangoLin on 2024/1/8.
//

import Foundation

struct Envirment {
    var api: ApiClient
    var imageProvider: ImageFetcher
    var reachability: ReachabilityClient
}

var Current = Envirment(
    api: .live,
    imageProvider: .live,
    reachability: .live(DispatchQueue.main)
)
