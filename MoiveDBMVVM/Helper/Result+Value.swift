//
//  Result+Value.swift
//  MoiveDBMVVM
//
//  Created by DjangoLin on 2024/1/3.
//

import Foundation

extension Result {
    var success: Success? {
        switch self {
        case .success(let data):
            return data
        default:
            return nil
        }
    }

    var failure: Failure? {
        switch self {
        case .success:
            return nil
        case .failure(let failure):
            return failure
        }
    }
}
