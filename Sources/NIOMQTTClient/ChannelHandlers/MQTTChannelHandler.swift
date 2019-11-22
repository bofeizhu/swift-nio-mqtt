//
//  MQTTChannelHandler.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 9/6/19.
//  Copyright © 2019 Bofei Zhu. All rights reserved.
//

import NIO
import MQTTCodec

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
        let controlPacket = unwrapInboundIn(data)

        switch controlPacket {
        case let .connAck(packet):
            let variableHeader = packet.variableHeader
            let reasonCode = variableHeader.connectReasonCode

            if reasonCode == .success {
                let properties = variableHeader.properties
                connAckPromise.succeed((context.channel, properties))
            } else {
                // TODO: Handle connect acknowledgement errors
            }

        case let .publish(packet):
            let topic = packet.variableHeader.topicName
            let payload = packet.payload
            publishHandler(topic, payload)
            do {
                guard let acknowledgePacket = try session.acknowledge(packet) else {
                    return
                }

                context.writeAndFlush(wrapOutboundOut(acknowledgePacket), promise: nil)
            } catch {
                context.fireErrorCaught(error)
            }

        case let .pubAck(packet):
            do {
                try session.acknowledge(with: packet)
            } catch {
                context.fireErrorCaught(error)
            }

        default:
            context.fireChannelRead(data)
        }
    }

    func write(context: ChannelHandlerContext, data: NIOAny, promise: EventLoopPromise<Void>?) {
        let action = unwrapOutboundIn(data)
        let packet = session.makeControlPacket(for: action, promise: promise)
        context.writeAndFlush(wrapOutboundOut(packet), promise: nil)
    }
}
