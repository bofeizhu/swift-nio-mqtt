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

    public var onText: ((String, String) -> Void)?
    public var onData: ((String, Data) -> Void)?

    /// A monitor for the connectivity state.
    public let connectivity: ConnectivityStateMonitor

    private let group: NIOTSEventLoopGroup
    private let host: String
    private let port: Int
    private var channel: Channel?

    /// Where the callback is executed. It defaults to the main queue.
    private let callbackQueue: DispatchQueue = DispatchQueue.main

    public init(host: String, port: Int) {
        group = NIOTSEventLoopGroup()

        self.host = host
        self.port = port

        // TODO: Add delegate
        connectivity = ConnectivityStateMonitor(delegate: nil)
    }

    public func connect() {

    }

    @discardableResult
    public func publish(topic: String, message: String) -> EventLoopFuture<Void>? {
        let action: Session.Action = .publish(topic: topic, payload: .utf8(stirng: message))
        return channel?.writeAndFlush(action)
    }

    @discardableResult
    public func subscribe(topic: String) -> EventLoopFuture<Void>? {
        let action: Session.Action = .subscribe(topic: topic)
        return channel?.writeAndFlush(action)
    }

    @discardableResult
    public func unsubscribe(topic: String) -> EventLoopFuture<Void>? {
        let action: Session.Action = .unsubscribe(topic: topic)
        return channel?.writeAndFlush(action)
    }
}

// MARK: - Channel Creation

extension MQTT {

    private func makeChannel() -> EventLoopFuture<Channel> {
        guard connectivity.state == .idle || connectivity.state == .transientFailure else {
            return group.next().makeFailedFuture(MQTTStatus.internalError)
        }

        connectivity.state = .connecting

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
            connectPacket: connectPacket,
            connAckPromise: connAckPromise,
            publishHandler: publishHandler)

        let bootstrap = MQTT.makeBootstrap(group: group, mqttChannelHandler: mqttChannelHandler)

        let connection = bootstrap.connect(host: host, port: port)
        connection.cascadeFailure(to: connAckPromise)

        return connAckPromise.futureResult.flatMap { (channel, properties) -> EventLoopFuture<Channel> in
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
