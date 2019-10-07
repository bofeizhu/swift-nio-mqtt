//
//  MQTT.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 8/29/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

import Network
import Dispatch
import NIO
import NIOTransportServices

public final class MQTT {

    public var onConnect: (() -> Void)?
    public var onDisconnect: ((Error?) -> Void)?
    public var onText: ((String, String) -> Void)?
    public var onData: ((String, Data) -> Void)?

    /// A monitor for the connectivity state.
    public let connectivity: ConnectivityStateMonitor

    /// The configuration for this client.
    let configuration: Configuration

    private let group: NIOTSEventLoopGroup
    private var channel: EventLoopFuture<Channel> {
        willSet {
            willSetChannel(to: newValue)
        }
        didSet {
            didSetChannel(to: self.channel)
        }
    }
    private var session: Session

    /// Where the callback is executed. It defaults to the main queue.
    private let callbackQueue: DispatchQueue = DispatchQueue.main

    /// Creates a new connection from the given configuration.
    public init(configuration: Configuration) {
        self.configuration = configuration

        group = NIOTSEventLoopGroup()
        channel = group.next().makeFailedFuture(MQTTStatus.unavailable)
        connectivity = ConnectivityStateMonitor()
        session = Session(qos: configuration.qos)

        connectivity.delegate = self
    }

    public func connect() {
        channel = makeChannel(
            backoffIterator: configuration.connectionBackoff?.makeIterator())
    }

    @discardableResult
    public func publish(topic: String, message: String) -> EventLoopFuture<Void>? {
        let action: Session.Action = .publish(topic: topic, payload: .utf8(stirng: message))
        return channel.flatMap { channel in
            channel.writeAndFlush(action)
        }
    }

    @discardableResult
    public func subscribe(topic: String) -> EventLoopFuture<Void>? {
        let action: Session.Action = .subscribe(topic: topic)
        return channel.flatMap { channel in
            channel.writeAndFlush(action)
        }
    }

    @discardableResult
    public func unsubscribe(topic: String) -> EventLoopFuture<Void>? {
        let action: Session.Action = .unsubscribe(topic: topic)
        return channel.flatMap { channel in
            channel.writeAndFlush(action)
        }
    }
}

// MARK: - Channel Creation

extension MQTT {

    /// Register a callback on the close future of the given `channel` to replace the channel (if possible).
    ///
    /// - Parameter channel: The channel that will be set.
    private func willSetChannel(to channel: EventLoopFuture<Channel>) {
        // If we're about to set the channel and the user has initiated a shutdown (i.e. while the new
        // channel was being created) then it is no longer needed.
        guard !connectivity.userHasInitiatedShutdown else {
            channel.whenSuccess { channel in
                channel.close(mode: .all, promise: nil)
            }
            return
        }

        // If we get a channel and it closes then create a new one, if necessary.
        channel.flatMap { $0.closeFuture }.whenComplete { _ in
            // TODO: Add result logging
            guard self.connectivity.canAttemptReconnect else {
              return
            }

            // Something went wrong, but we'll try to fix it so let's update our state to reflect that.
            self.connectivity.state = .transientFailure
            self.channel = self.makeChannel(
                backoffIterator: self.configuration.connectionBackoff?.makeIterator())
        }
    }

    /// Register a callback on the given `channel` to update the connectivity state.
    ///
    /// - Parameter channel: The channel that was set.
    private func didSetChannel(to channel: EventLoopFuture<Channel>) {
        channel.whenFailure { _ in
            self.connectivity.state = .shutdown
        }
    }

    private func makeChannel(
        backoffIterator: ConnectionBackoffIterator?
    ) -> EventLoopFuture<Channel> {
        guard connectivity.state == .idle || connectivity.state == .transientFailure else {
            return group.next().makeFailedFuture(MQTTStatus.internalError)
        }

        connectivity.state = .connecting
        let timeoutAndBackoff = backoffIterator?.next()

        let connectPacket = makeConnectPacket()
        let connAckPromise: EventLoopPromise<(Channel, PropertyCollection)> = group.next().makePromise()
        let publishHandler: PublishHandler = { [weak self] (topic, payload) in
            guard let self = self else {
                return
            }

            self.callbackQueue.async {
                switch payload {
                case let .utf8(text):
                    self.onText?(topic, text)

                case let .binary(data):
                    self.onData?(topic, data)

                case .empty:
                    break
                }
            }
        }

        let mqttChannelHandler = MQTTChannelHandler(
            session: session,
            connectPacket: connectPacket,
            connAckPromise: connAckPromise,
            publishHandler: publishHandler)

        let bootstrap = MQTT.makeBootstrap(group: group, mqttChannelHandler: mqttChannelHandler)

        let connection = bootstrap.connect(host: configuration.host, port: configuration.port)
        connection.cascadeFailure(to: connAckPromise)

        let channel = connAckPromise.futureResult.flatMap { (channel, properties) -> EventLoopFuture<Channel> in
            self.connectivity.state = .ready

            var keepAlive = connectPacket.variableHeader.keepAlive

            if let serverKeepAlive = properties.serverKeepAlive {
                keepAlive = serverKeepAlive
            }

            // If Keep Alive is 0 the Client is not obliged to send MQTT Control Packets on any particular schedule.
            guard keepAlive > 0 else {
                return channel.pipeline.eventLoop.makeSucceededFuture(channel)
            }

            let timeout: TimeAmount = .seconds(TimeAmount.Value(keepAlive))
            let channelHandlers: [ChannelHandler] = [
                IdleStateHandler(writeTimeout: timeout),
                KeepAliveHandler()
            ]
            return channel.pipeline
                .addHandlers(channelHandlers, position: .before(mqttChannelHandler))
                .map { channel }
        }

        // If we don't have backoff then we can't retry, just return the `channel` no matter what
        // state we are in.
        guard let backoff = timeoutAndBackoff?.backoff else {
          return channel
        }

        // If our connection attempt was unsuccessful, schedule another attempt in some time.
        return channel.flatMapError { _ in
            // TODO: Log error

            // We will try to connect again: the failure is transient.
            self.connectivity.state = .transientFailure
            return self.scheduleReconnectAttempt(in: backoff, backoffIterator: backoffIterator)
        }
    }

    private func scheduleReconnectAttempt(
        in timeout: TimeInterval,
        backoffIterator: ConnectionBackoffIterator?
    ) -> EventLoopFuture<Channel> {
        return group.next().scheduleTask(in: .seconds(timeInterval: timeout)) {
            self.makeChannel(backoffIterator: backoffIterator)
        }.futureResult.flatMap { channel in
            channel
        }
    }

    // TODO: Return a `ClientBootstrapProtocol` instead
    private static func makeBootstrap(
        group: EventLoopGroup,
        mqttChannelHandler: MQTTChannelHandler
    ) -> NIOTSConnectionBootstrap {

        // Disable TLS for now
        //let tlsOptions = makeTLSOptions()

        return NIOTSConnectionBootstrap(group: group)
            .channelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
            .channelOption(ChannelOptions.socket(SocketOptionLevel(IPPROTO_TCP), TCP_NODELAY), value: 1)
            //.tlsOptions(tlsOptions)
            .channelInitializer { channel in
                initializeChannel(channel, mqttChannelHandler: mqttChannelHandler)
            }
    }

    private static func initializeChannel(
        _ channel: Channel,
        mqttChannelHandler: MQTTChannelHandler
    ) -> EventLoopFuture<Void> {
        let controlPacketEncoder = MessageToByteHandler(ControlPacketEncoder())
        let controlPacketDecoder = ByteToMessageHandler(ControlPacketDecoder())

        let loggingHandler = LoggingHandler()

        let handlers: [ChannelHandler] = [
            controlPacketEncoder,
            controlPacketDecoder,
            loggingHandler,
            mqttChannelHandler,
        ]

        return channel.pipeline.addHandlers(handlers)
    }

    private func makeConnectPacket() -> ConnectPacket {
        let variableHeader = ConnectPacket.VariableHeader(
            connectFlags: ConnectPacket.ConnectFlags(rawValue: 2)!,
            keepAlive: 30,
            properties: PropertyCollection())

        let payload = ConnectPacket.Payload(
            clientId: "HealthTap",
            willMessage: nil,
            username: nil,
            password: nil)

        return ConnectPacket(variableHeader: variableHeader, payload: payload)
    }

    private func makeTLSOptions() -> NWProtocolTLS.Options {
        let options = NWProtocolTLS.Options()

        // Disable peer authentication for now
        sec_protocol_options_set_peer_authentication_required(options.securityProtocolOptions, false)

        return options
    }
}

// MARK: - Connectivity State Delegate

extension MQTT: ConnectivityStateDelegate {
    func connectivityStateDidChange(from oldState: ConnectivityState, to newState: ConnectivityState) {
        switch newState {
        case .ready:
            onConnect?()
        default:
            break
        }
    }
}

// MARK: - Helpers

fileprivate extension TimeAmount {
    /// Creates a new `TimeAmount` from the given time interval in seconds.
    ///
    /// - Parameter timeInterval: The amount of time in seconds
    static func seconds(timeInterval: TimeInterval) -> TimeAmount {
        return .nanoseconds(Int64(timeInterval * 1_000_000_000))
    }
}
