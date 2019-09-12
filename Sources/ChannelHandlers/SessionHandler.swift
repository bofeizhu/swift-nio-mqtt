//
//  SessionHandler.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 9/6/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

import NIO

final class SessionHandler: ChannelDuplexHandler {
    typealias InboundIn = ControlPacket
    typealias InboundOut = ControlPacket
    typealias OutboundIn = Session.Action
    typealias OutboundOut = ControlPacket

    private let session: Session

    init(session: Session = Session()) {
        self.session = session
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

        case .unsubscribe:
            break
        }
    }

    private func makePublishPacket(topic: String, payload: PublishPacket.Payload) -> PublishPacket {
        var properties = PropertyCollection()
        // properties.append(payload.formatIndicator)

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
        let variableHeader = SubscribePacket.VariableHeader(packetIdentifier: 1, properties: PropertyCollection())
        let topicFilter = SubscribePacket.TopicFilter(
            topic: topic,
            options: SubscribePacket.Options(rawValue: 0)!)
        let payload = SubscribePacket.Payload(topicFilters: [topicFilter])
        let packet = SubscribePacket(variableHeader: variableHeader, payload: payload)
        return packet
    }
}
