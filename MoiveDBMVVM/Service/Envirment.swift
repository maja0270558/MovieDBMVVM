//
//  Envirment.swift
//  MoiveDBMVVM
//
//  Created by DjangoLin on 2024/1/8.
//

import Foundation

struct Envirment {
    var api: ApiClient
    var aTestString = "live  😁"
}

var Current = Envirment(api: .current)
