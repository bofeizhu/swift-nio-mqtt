//
//  SubscribePacketBuilder.swift
//  MQTTCodec
//
//  Created by Bofei Zhu on 11/13/19.
//  Copyright © 2019 Bofei Zhu. All rights reserved.
//

public final class SubscribePacketBuilder {

    private var packetIdentifier: UInt16

    private var topicFilters: [SubscribePacket.TopicFilter] = []

    private var properties = PropertyCollection()

    public init(packetIdentifier: UInt16) {
        self.packetIdentifier = packetIdentifier
    }

    public func addSubscription(topic: String, qos: QoS) -> SubscribePacketBuilder {
        let options = SubscribePacket.Options(qos: qos)
        let topicFilter = SubscribePacket.TopicFilter(topic: topic, options: options)
        topicFilters.append(topicFilter)

        return self
    }

    /// Build SUBSCRIBE packet.
    ///
    /// - Returns: A SUBSCRIBE packet.
    public func build() -> SubscribePacket {
        let variableHeader = SubscribePacket.VariableHeader(
            packetIdentifier: packetIdentifier,
            properties: properties)

        let payload = SubscribePacket.Payload(topicFilters: topicFilters)

        return SubscribePacket(variableHeader: variableHeader, payload: payload)
    }
}
