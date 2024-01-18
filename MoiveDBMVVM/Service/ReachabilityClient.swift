//
//  PathMonitorClient.swift
//  MoiveDBMVVM
//
//  Created by DjangoLin on 2024/1/17.
//

import Combine
import Foundation
import Network

struct ReachabilityClient {
    var pathUpdatePublisher: AnyPublisher<NWPath, Never>
}

extension ReachabilityClient {
    public static func live(_ queue: DispatchQueue) -> Self {
        return .init(pathUpdatePublisher:  {
            let subject = PassthroughSubject<NWPath, Never>()
            var monitor = NWPathMonitor()
            monitor.pathUpdateHandler = subject.send

            return subject
                .handleEvents(
                    receiveSubscription: { _ in monitor.start(queue: queue) },
                    receiveCancel: { monitor.cancel() }
                )
                .eraseToAnyPublisher()
        }())
    }
}
