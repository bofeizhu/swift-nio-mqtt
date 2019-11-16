//
//  Session.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 9/10/19.
//  Copyright © 2019 Bofei Zhu. All rights reserved.
//

import NIO

final class Session {

    private let qos: QoS

    private var nextPacketIdentifier: UInt16 {
        if packetIdentifier == UInt16.max {
            packetIdentifier = 1
        } else {
            packetIdentifier += 1
        }
        return packetIdentifier
    }

    private var publishStore: Store<(PublishPacket, EventLoopPromise<Void>?)> = Store()

    private var packetIdentifier: UInt16 = 0

    init(qos: QoS = .atMostOnce) {
        self.qos = qos
    }

    func makeControlPacket(for action: Action, promise: EventLoopPromise<Void>?) -> ControlPacket {
        switch action {
        case let .publish(topic, payload):
            let packet = makePublishPackets(topic: topic, payload: payload)

            if let identifier = packet.variableHeader.packetIdentifier {
                publishStore.append((packet, promise), withIdentifier: identifier)
            }
            return .publish(packet: packet)

        case let .subscribe(topic):
            let packet = makeSubscribePacket(topic: topic)
            return .subscribe(packet: packet)

        case let .unsubscribe(topic):
            let packet = makeUnsubscribePacket(topic: topic)
            return .unsubscribe(packet: packet)
        }
    }

    func acknowledge(_ publishPacket: PublishPacket) throws -> ControlPacket? {
        let fixedHeader = publishPacket.fixedHeader
        switch fixedHeader.flags {
        case let .publish(_, qos, _):
            switch qos {
            case .atLeastOnce:
                guard let packetIdentifier = publishPacket.variableHeader.packetIdentifier else {
                     throw MQTTCodingError.malformedPacket
                }
                let pubAckPacket = PubAckPacketBuilder(packetIdentifier: packetIdentifier).build()
                return .pubAck(packet: pubAckPacket)

            default:
                // TODO: Add QoS level 2.
                return nil
            }
        default:
            // Wrong fixed header.
            throw MQTTCodingError.malformedPacket
        }
    }

    func acknowledge(with pubAckPacket: PubAckPacket) throws {
        let identifier = pubAckPacket.variableHeader.packetIdentifier
        guard let (_, promise) = publishStore.removeElement(forIdentifier: identifier) else {
            throw MQTTError(type: .malformedPacket, message: "PUBACK packet identifier does not exist.")
        }

        promise?.succeed(())
    }

    private func makePublishPackets(
        topic: String,
        payload: PublishPacket.Payload
    ) -> PublishPacket {
        var properties = PropertyCollection()
        properties.append(payload.formatIndicator)

        let packetIdentifier = qos.rawValue == 0 ? nil : nextPacketIdentifier

        let variableHeader = PublishPacket.VariableHeader(
            topicName: topic,
            packetIdentifier: packetIdentifier,
            properties: properties)

        let packet = PublishPacket(
            dup: false,
            qos: qos,
            retain: false,
            variableHeader: variableHeader,
            payload: payload)

        return packet
    }

    private func makeSubscribePacket(topic: String) -> SubscribePacket {
        let packetIdentifier = nextPacketIdentifier
        let packet = SubscribePacketBuilder(packetIdentifier: packetIdentifier)
            .addSubscription(topic: topic, qos: qos)
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
