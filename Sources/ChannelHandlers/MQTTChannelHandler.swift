//
//  MQTTChannelHandler.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 9/6/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

import NIO

typealias PublishHandler = (String, PublishPacket.Payload) -> Void

final class MQTTChannelHandler: ChannelDuplexHandler {
    typealias InboundIn = ControlPacket
    typealias InboundOut = ControlPacket
    typealias OutboundIn = Session.Action
    typealias OutboundOut = ControlPacket

    private let session: Session
    private let connectPacket: ConnectPacket
    private let connAckPromise: EventLoopPromise<(Channel, PropertyCollection)>
    private let publishHandler: PublishHandler

    init(
        session: Session = Session(),
        connectPacket: ConnectPacket,
        connAckPromise: EventLoopPromise<(Channel, PropertyCollection)>,
        publishHandler: @escaping PublishHandler
    ) {
        self.session = session
        self.connectPacket = connectPacket
        self.connAckPromise = connAckPromise
        self.publishHandler = publishHandler
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
        case let .publish(publishPacket):
            let topic = publishPacket.variableHeader.topicName
            let payload = publishPacket.payload
            publishHandler(topic, payload)

        default:
            context.fireChannelRead(data)
        }
    }

    func write(context: ChannelHandlerContext, data: NIOAny, promise: EventLoopPromise<Void>?) {
        // TODO: Cache promises
        let action = unwrapOutboundIn(data)
        let packet = session.makeControlPacket(for: action)

        context.writeAndFlush(wrapOutboundOut(packet), promise: promise)
    }
}
