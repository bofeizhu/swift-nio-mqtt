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
    private let connAckPromise: EventLoopPromise<Void>

    init(connectPacket: ConnectPacket, connAckPromise: EventLoopPromise<Void>) {
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
                connectAcknowledged(
                    context: context,
                    properties: properties
                ).cascade(to: connAckPromise)
            } else {
                // TODO: Handle connect acknowledgement errors
            }

        default:
            // Handle error
            break
        }
    }

    private func connectAcknowledged(
        context: ChannelHandlerContext,
        properties: PropertyCollection
    ) -> EventLoopFuture<Void> {

        var keepAlive = connectPacket.variableHeader.keepAlive

        if let serverKeepAlive = properties.serverKeepAlive {
            keepAlive = serverKeepAlive
        }

        var handlers: [ChannelHandler] = []

        // If Keep Alive is 0 the Client is not obliged to send MQTT Control Packets on any particular schedule.
        if keepAlive > 0 {
            handlers.append(KeepAliveHandler(keepAlive: keepAlive))
        }

        // TODO: Add Sub/Pub handlers
        return context.channel.pipeline.addHandlers(handlers)
            .flatMap {
                return context.pipeline.removeHandler(self)
            }
    }
}
