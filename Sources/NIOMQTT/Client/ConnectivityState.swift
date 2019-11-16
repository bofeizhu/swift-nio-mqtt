//
//  ConnectivityState.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 9/26/19.
//  Copyright © 2019 Bofei Zhu. All rights reserved.
//

import Foundation
import NIOConcurrencyHelpers

/// The connectivity state of a MQTT client connection.
public enum ConnectivityState {
    /// This is the state where the channel has not yet been created.
    case idle

    /// The channel is trying to establish a connection and is waiting for the connect acknowledge from the broker.
    case connecting

    /// The channel has successfully established a connection.
    case ready

    /// There has been some transient failure. Channels in this state will eventually switch to
    /// the `.connecting` state and try to establish a connection again.
    /// Since retries are done with exponential backoff, channels that fail to connect
    /// will start out spending very little time in this state but as the attempts
    /// fail repeatedly, the channel will spend increasingly large amounts of time in this state.
    case transientFailure

    /// This channel has started shutting down. Channels may enter this state either
    /// because the application explicitly requested a shutdown or if a non-recoverable error has
    /// happened during attempts to connect. Channels that have entered this state will never leave this state.
    case shutdown
}

protocol ConnectivityStateDelegate: AnyObject {
    /// Called when a change in `ConnectivityState` has occurred.
    ///
    /// - Parameter oldState: The old connectivity state.
    /// - Parameter newState: The new connectivity state.
    func connectivityStateDidChange(from oldState: ConnectivityState, to newState: ConnectivityState)
}

public final class ConnectivityStateMonitor {
    /// A delegate to call when the connectivity state changes.
    weak var delegate: ConnectivityStateDelegate?

    private let lock = Lock()
    private var currentState: ConnectivityState = .idle
    private var userInitiatedShutdown = false

    /// Creates a new connectivity state monitor.
    init() {}

    /// The current state of connectivity.
    public internal(set) var state: ConnectivityState {
        get { lock.withLock { currentState } }

        set { lock.withLockVoid { setNewState(to: newValue) } }
    }

    /// Whether the user has initiated a shutdown or not.
    var userHasInitiatedShutdown: Bool {
        lock.withLock { userInitiatedShutdown }
    }

    /// Whether we can attempt a reconnection, that is the user has not initiated a shutdown and we
    /// are in the `.ready` state.
    var canAttemptReconnect: Bool {
        lock.withLock { !userInitiatedShutdown && currentState == .ready }
    }

    /// Initiates a user shutdown.
    func initiateUserShutdown() {
        lock.withLockVoid {
            setNewState(to: .shutdown)
            userInitiatedShutdown = true
        }
    }

    /// Updates `state` to `newState`.
    ///
    /// If the user has initiated shutdown then state updates are _ignored_. This may happen if the
    /// connection is being estabilshed as the user initiates shutdown.
    ///
    /// - Important: This is **not** thread safe.
    private func setNewState(to newState: ConnectivityState) {
        guard !userInitiatedShutdown else {
            return
        }

        let oldState = currentState
        if oldState != newState {
            currentState = newState
            delegate?.connectivityStateDidChange(from: oldState, to: newState)
        }
    }
}
