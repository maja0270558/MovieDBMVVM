//
//  Envirment.swift
//  MoiveDBMVVM
//
//  Created by DjangoLin on 2024/1/8.
//

import Foundation

struct Envirment {
    var api: ApiClient
}

extension Envirment {
    static var current: Self = .live
}

extension Envirment {
    static let live: Self = {
        Envirment(api: .current)
    }()
}
