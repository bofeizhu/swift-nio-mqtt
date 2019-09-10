//
//  ConnectHandler.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 8/30/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

import NIO

final class ConnectHandler: ChannelInboundHandler, RemovableChannelHandler {
    typealias InboundIn = ControlPacket
    typealias OutboundOut = ControlPacket

    private let connectPacket: ConnectPacket
    private let connAckPromise: EventLoopPromise<(Channel, PropertyCollection)>

    init(
        connectPacket: ConnectPacket,
        connAckPromise: EventLoopPromise<(Channel, PropertyCollection)>
    ) {
        self.connectPacket = connectPacket
        self.connAckPromise = connAckPromise
    }

    func channelActive(context: ChannelHandlerContext) {

        // Send CONNECT packet
        context.writeAndFlush(wrapOutboundOut(.connect(packet: connectPacket)), promise: nil)
    }

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {

        let packet = unwrapInboundIn(data)

        switch packet {

        case let .connAck(connAckPacket):
            let variableHeader = connAckPacket.variableHeader
            let reasonCode = variableHeader.connectReasonCode

            if reasonCode == .success {
                let properties = variableHeader.properties
                connAckPromise.succeed((context.channel, properties))
            } else {
                // TODO: Handle connect acknowledgement errors
            }

        default:
            // Handle error
            break
        }
    }
}
