//
//  Session.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 9/10/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

import NIO

final class Session {

    private let qos: QoS

    private var nextPacketIdentifier: UInt16 {
        if packetIdentifier == UInt16.max {
            packetIdentifier = 1
        }
        return packetIdentifier
    }

    private var unacknowledgedPublishPackets: CircularBuffer<PublishPacket> = CircularBuffer()

    private var packetIdentifier: UInt16 = 1

    init(qos: QoS = .atMostOnce) {
        self.qos = qos
    }

    func makeControlPacket(for action: Action) -> ControlPacket {
        switch action {
        case let .publish(topic, payload):
            let packet = makePublishPackets(topic: topic, payload: payload)
            return .publish(packet: packet)

        case let .subscribe(topic):
            let packet = makeSubscribePacket(topic: topic)
            return .subscribe(packet: packet)

        case let .unsubscribe(topic):
            let packet = makeUnsubscribePacket(topic: topic)
            return .unsubscribe(packet: packet)
        }
    }

    private func makePublishPackets(
        topic: String,
        payload: PublishPacket.Payload,
        dup: Bool = false
    ) -> PublishPacket {
        var properties = PropertyCollection()
        properties.append(payload.formatIndicator)

        let packetIdentifier = qos.rawValue == 0 ? nil : nextPacketIdentifier

        let variableHeader = PublishPacket.VariableHeader(
            topicName: topic,
            packetIdentifier: packetIdentifier,
            properties: properties)

        let packet = PublishPacket(
            dup: dup,
            qos: qos,
            retain: false,
            variableHeader: variableHeader,
            payload: payload)

        unacknowledgedPublishPackets.append(packet)

        return packet
    }

    private func makeSubscribePacket(topic: String) -> SubscribePacket {
        let packetIdentifier = nextPacketIdentifier
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
        let packetIdentifier = nextPacketIdentifier
        let variableHeader = UnsubscribePacket.VariableHeader(
            packetIdentifier: packetIdentifier,
            properties: PropertyCollection())

        let payload = UnsubscribePacket.Payload(topicFilters: [topic])
        return UnsubscribePacket(variableHeader: variableHeader, payload: payload)
    }
}
