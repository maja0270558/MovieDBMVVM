//
//  PathMonitorClient.swift
//  MoiveDBMVVM
//
//  Created by DjangoLin on 2024/1/17.
//

import Combine
import Foundation
import Network

struct NetworkPath: Equatable {
    var status: NWPath.Status
}

extension NetworkPath {
    init(rawValue: NWPath) {
        self.status = rawValue.status
    }
}

public struct ReachabilityClient {
    var pathUpdatePublisher: AnyPublisher<NetworkPath, Never>
}

public extension ReachabilityClient {
    static func live(_ queue: DispatchQueue) -> Self {
        return .init(pathUpdatePublisher: {
            let subject = PassthroughSubject<NWPath, Never>()
            let monitor = NWPathMonitor()
            monitor.pathUpdateHandler = subject.send

            return subject
                .map(NetworkPath.init(rawValue:))
                .handleEvents(
                    receiveSubscription: { _ in monitor.start(queue: queue) },
                    receiveCancel: { monitor.cancel() }
                )
                .eraseToAnyPublisher()
        }())
    }

    static let satisfied: Self = .init(
        pathUpdatePublisher: Just<NetworkPath>(
            .init(status: .satisfied)
        )
        .eraseToAnyPublisher()
    )

    static let unsatisfied: Self = .init(
        pathUpdatePublisher: Just<NetworkPath>(
            .init(status: .unsatisfied)
        )
        .eraseToAnyPublisher()
    )
}
