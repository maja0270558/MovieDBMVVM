//
//  HttpClientLive.swift
//  MoiveDBMVVM
//
//  Created by DjangoLin on 2023/12/19.
//

import Foundation

extension APIClient {
    static var current: Self = .init(
        session: NetworrkSession.live
    )
}
