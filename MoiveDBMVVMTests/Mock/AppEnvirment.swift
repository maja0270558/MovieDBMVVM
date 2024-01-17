//
//  AppEnvirment.swift
//  MoiveDBMVVMTests
//
//  Created by DjangoLin on 2024/1/16.
//

import Foundation
@testable import MoiveDBMVVM

extension Envirment {
    static let mock: Self = {
        return .init(api: .noop,
                     imageProvider: .mock)
    }()
}
