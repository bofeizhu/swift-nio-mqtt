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

    public func connect() {

        // let connAckPromise: EventLoopPromise<Void> = group.next().makePromise()

        let bootstrap = NIOTSConnectionBootstrap(group: group)
            .channelOption(ChannelOptions.socket(SocketOptionLevel(IPPROTO_TCP), TCP_NODELAY), value: 1)
            .tlsOptions(NWProtocolTLS.Options())
            .channelInitializer { channel -> EventLoopFuture<Void> in

                let controlPacketEncoder = MessageToByteHandler(ControlPacketEncoder())
                let controlPacketDecoder = ByteToMessageHandler(ControlPacketDecoder())

                let handlers: [ChannelHandler] = [
                    controlPacketEncoder,
                    controlPacketDecoder,
                ]

                return channel.pipeline.addHandlers(handlers)
            }

        let _ = bootstrap.connect(host: host, port: port)
    }
}
