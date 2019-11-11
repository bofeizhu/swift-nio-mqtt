//
//  ConnectionBackoff.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 9/28/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

import Foundation

public struct ConnectionBackoff: Sequence {
    public typealias Iterator = ConnectionBackoffIterator

    /// The initial backoff in seconds.
    public var initialBackoff: TimeInterval

    /// The maximum backoff in seconds. Note that the backoff is _before_ jitter has been applied,
    /// this means that in practice the maximum backoff can be larger than this value.
    public var maximumBackoff: TimeInterval

    /// The backoff multiplier.
    public var multiplier: Double

    /// Backoff jitter; should be between 0 and 1.
    public var jitter: Double

    /// The minimum amount of time in seconds to try connecting.
    public var minimumConnectionTimeout: TimeInterval

    /// Creates a `ConnectionBackoff`.
    ///
    /// - Parameter initialBackoff: Initial backoff in seconds, defaults to 1.0.
    /// - Parameter maximumBackoff: Maximum backoff in seconds (prior to adding jitter), defaults to 120.0.
    /// - Parameter multiplier: Backoff multiplier, defaults to 1.6.
    /// - Parameter jitter: Backoff jitter, defaults to 0.2.
    /// - Parameter minimumConnectionTimeout: Minimum connection timeout in seconds, defaults to 20.0.
    public init(
        initialBackoff: TimeInterval = 1.0,
        maximumBackoff: TimeInterval = 120.0,
        multiplier: Double = 1.6,
        jitter: Double = 0.2,
        minimumConnectionTimeout: TimeInterval = 20.0
    ) {
        self.initialBackoff = initialBackoff
        self.maximumBackoff = maximumBackoff
        self.multiplier = multiplier
        self.jitter = jitter
        self.minimumConnectionTimeout = minimumConnectionTimeout
    }

    public func makeIterator() -> ConnectionBackoff.Iterator {
        return Iterator(connectionBackoff: self)
    }
}

/// An iterator for `ConnectionBackoff`.
public class ConnectionBackoffIterator: IteratorProtocol {
    public typealias Element = (timeout: TimeInterval, backoff: TimeInterval)

    /// The configuration being used.
    private let connectionBackoff: ConnectionBackoff

    /// The backoff in seconds, without jitter.
    private var unjitteredBackoff: TimeInterval

    /// The first element to return. Since the first backoff is defined as `initialBackoff` we can't
    /// compute it on-the-fly.
    private var initialElement: Element?

    /// Creates a new connection backoff iterator with the given configuration.
    public init(connectionBackoff: ConnectionBackoff) {
        self.connectionBackoff = connectionBackoff
        self.unjitteredBackoff = connectionBackoff.initialBackoff

        // Since the first backoff is `initialBackoff` it must be generated here instead of
        // by `makeNextElement`.
        let backoff = min(connectionBackoff.initialBackoff, connectionBackoff.maximumBackoff)
        initialElement = makeElement(backoff: backoff)
    }

    /// Returns the next pair of connection timeout and backoff (in that order) to use should the
    /// connection attempt fail.
    public func next() -> Element? {
        if let initial = initialElement {
            initialElement = nil
            return initial
        } else {
            return makeNextElement()
        }
    }

    /// Produces the next element to return.
    private func makeNextElement() -> Element {
        let unjittered = unjitteredBackoff * connectionBackoff.multiplier
        unjitteredBackoff = min(unjittered, connectionBackoff.maximumBackoff)

        let backoff = jittered(value: unjitteredBackoff)
        return makeElement(backoff: backoff)
    }

    /// Make a timeout-backoff pair from the given backoff. The timeout is the `max` of the backoff
    /// and `connectionBackoff.minimumConnectionTimeout`.
    private func makeElement(backoff: TimeInterval) -> Element {
        let timeout = max(backoff, connectionBackoff.minimumConnectionTimeout)
        return (timeout, backoff)
    }

    /// Adds 'jitter' to the given value.
    private func jittered(value: TimeInterval) -> TimeInterval {
        let lower = -connectionBackoff.jitter * value
        let upper = connectionBackoff.jitter * value
        return value + TimeInterval.random(in: lower...upper)
    }
}
