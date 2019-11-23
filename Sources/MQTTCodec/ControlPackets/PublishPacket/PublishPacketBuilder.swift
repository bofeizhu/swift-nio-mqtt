//
//  PublishPacketBuilder.swift
//  MQTTCodec
//
//  Created by Bofei Zhu on 11/22/19.
//  Copyright © 2019 Bofei Zhu. All rights reserved.
//

public final class PublishPacketBuilder {

    private var dup: Bool = false

    private var qos: QoS = .atMostOnce

    private var retain: Bool = false

    private var packetIdentifier: UInt16?

    private let topic: String

    private let payload: PublishPacket.Payload

    public init(topic: String, payload: PublishPacket.Payload) {
        self.topic = topic
        self.payload = payload
    }

    /// Set DUP Flag.
    public func dup(_ dup: Bool) -> PublishPacketBuilder {
        self.dup = dup
        return self
    }

    /// Set QoS flag.
    ///
    /// - Important:
    public func qos(_ qos: QoS) -> PublishPacketBuilder {
        self.qos = qos
        return self
    }

    /// Set RETAIN Flag.
    public func retain(_ retain: Bool) -> PublishPacketBuilder {
        self.retain = retain
        return self
    }

    public func packetIdentifier(_ packetIdentifier: UInt16?) -> PublishPacketBuilder {
        self.packetIdentifier = packetIdentifier
        return self
    }

    /// Build PUBLISH packet.
    ///
    /// - Returns: A PUBLISH packet.
    public func build() -> PublishPacket {
        var properties = PropertyCollection()
        properties.append(payload.formatIndicator)

        let packetIdentifier = qos == .atMostOnce ? nil : self.packetIdentifier

        let variableHeader = PublishPacket.VariableHeader(
            topicName: topic,
            packetIdentifier: packetIdentifier,
            properties: properties)

        let publishPacket = PublishPacket(
            dup: dup,
            qos: qos,
            retain: retain,
            variableHeader: variableHeader,
            payload: payload)

        return publishPacket
    }
}
