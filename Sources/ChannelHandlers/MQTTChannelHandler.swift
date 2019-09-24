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

        switch action {
        case let .publish(topic, payload):
            let packet = makePublishPacket(topic: topic, payload: payload)
            context.writeAndFlush(wrapOutboundOut(.publish(packet: packet)), promise: promise)

        case let .subscribe(topic):
            let packet = makeSubscribePacket(topic: topic)
            context.writeAndFlush(wrapOutboundOut(.subscribe(packet: packet)), promise: promise)

        case let .unsubscribe(topic):
            let packet = makeUnsubscribePacket(topic: topic)
            context.writeAndFlush(wrapOutboundOut(.unsubscribe(packet: packet)), promise: promise)
        }
    }

    private func makePublishPacket(topic: String, payload: PublishPacket.Payload) -> PublishPacket {
        var properties = PropertyCollection()
        properties.append(payload.formatIndicator)

        let variableHeader = PublishPacket.VariableHeader(
            topicName: topic,
            packetIdentifier: nil,
            properties: properties)

        return PublishPacket(
            dup: false,
            qos: .level0,
            retain: false,
            variableHeader: variableHeader,
            payload: payload)
    }

    private func makeSubscribePacket(topic: String) -> SubscribePacket {
        let packetIdentifier = session.nextPacketIdentifier()
        let variableHeader = SubscribePacket.VariableHeader(
            packetIdentifier: packetIdentifier,
            properties: PropertyCollection())

        let topicFilter = SubscribePacket.TopicFilter(
            topic: topic,
            options: SubscribePacket.Options(rawValue: 0)!)

        let payload = SubscribePacket.Payload(topicFilters: [topicFilter])
        let packet = SubscribePacket(variableHeader: variableHeader, payload: payload)
        return packet
    }

    private func makeUnsubscribePacket(topic: String) -> UnsubscribePacket {
        let packetIdentifier = session.nextPacketIdentifier()
        let variableHeader = UnsubscribePacket.VariableHeader(
            packetIdentifier: packetIdentifier,
            properties: PropertyCollection())

        let payload = UnsubscribePacket.Payload(topicFilters: [topic])
        return UnsubscribePacket(variableHeader: variableHeader, payload: payload)
    }
}
