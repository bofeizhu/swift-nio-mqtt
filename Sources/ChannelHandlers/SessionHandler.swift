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
    typealias OutboundIn = ControlPacket
    typealias OutboundOut = ControlPacket

    init() {}

    func handlerAdded(context: ChannelHandlerContext) {
        let variableHeader = SubscribePacket.VariableHeader(packetIdentifier: 1, properties: PropertyCollection())
        let topicFilter = SubscribePacket.TopicFilter(
            topic: "healthtap",
            options: SubscribePacket.Options(rawValue: 0)!)
        let payload = SubscribePacket.Payload(topicFilters: [topicFilter])
        let packet = SubscribePacket(variableHeader: variableHeader, payload: payload)
        context.writeAndFlush(wrapOutboundOut(.subscribe(packet: packet)), promise: nil)
    }
}
