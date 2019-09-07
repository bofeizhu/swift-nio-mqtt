//
//  MQTT.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 8/29/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

import Network
import NIO
import NIOTransportServices

public final class MQTT {

    public var onConnect: (() -> Void)?

    private let group: NIOTSEventLoopGroup
    private let host: String
    private let port: Int

    public init(host: String, port: Int) {

        group = NIOTSEventLoopGroup()

        self.host = host
        self.port = port
    }

    public func connect() -> EventLoopFuture<Void> {

        let connectPacket = makeConnectPacket()
        let connAckPromise: EventLoopPromise<Void> = group.next().makePromise()

        let options = NWProtocolTLS.Options()

        // Disable peer authentication for now
        sec_protocol_options_set_peer_authentication_required(options.securityProtocolOptions, false)

        let bootstrap = NIOTSConnectionBootstrap(group: group)
            .channelOption(ChannelOptions.socket(SocketOptionLevel(IPPROTO_TCP), TCP_NODELAY), value: 1)
            .tlsOptions(options)
            .channelInitializer { channel -> EventLoopFuture<Void> in

                let controlPacketEncoder = MessageToByteHandler(ControlPacketEncoder())
                let controlPacketDecoder = ByteToMessageHandler(ControlPacketDecoder())

                let connectHandler = ConnectHandler(connectPacket: connectPacket, connAckPromise: connAckPromise)

                let loggingHandler = LoggingHandler()

                let handlers: [ChannelHandler] = [
                    controlPacketEncoder,
                    controlPacketDecoder,
                    loggingHandler,
                    connectHandler,
                ]

                return channel.pipeline.addHandlers(handlers)
            }

        let connection = bootstrap.connect(host: host, port: port).flatMap { $0.closeFuture }

        connection.cascadeFailure(to: connAckPromise)

        return connAckPromise.futureResult
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
}
