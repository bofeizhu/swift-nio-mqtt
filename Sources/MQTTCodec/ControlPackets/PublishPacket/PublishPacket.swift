//
//  PublishPacket.swift
//  MQTTCodec
//
//  Created by Bofei Zhu on 6/18/19.
//  Copyright © 2019 Bofei Zhu. All rights reserved.
//

/// PUBLISH packet – Publish message
///
/// A PUBLISH packet is sent from a Client to a Server or from a Server to a Client to
/// transport an Application Message.
public struct PublishPacket: ControlPacketProtocol {

    /// Fixed Header
    public let fixedHeader: FixedHeader

    /// DUP Flag
    public var dup: Bool

    /// QoS Flag
    public let qos: QoS

    /// RETAIN Flag
    public let retain: Bool

    /// Variable Header
    public let variableHeader: VariableHeader

    /// Payload
    public let payload: Payload

    init?(fixedHeader: FixedHeader, variableHeader: VariableHeader, payload: Payload) {

        switch fixedHeader.flags {
        case let .publish(dup, qos, retain):
            self.dup = dup
            self.qos = qos
            self.retain = retain

        default:
            return nil
        }

        self.fixedHeader = fixedHeader
        self.variableHeader = variableHeader
        self.payload = payload
    }

    init(dup: Bool, qos: QoS, retain: Bool, variableHeader: VariableHeader, payload: Payload) {
        let fixedHeaderFlags: FixedHeaderFlags = .publish(dup: dup, qos: qos, retain: retain)
        let remainingLength = variableHeader.mqttByteCount + payload.mqttByteCount

        fixedHeader = FixedHeader(type: .publish, flags: fixedHeaderFlags, remainingLength: remainingLength)
        self.dup = dup
        self.qos = qos
        self.retain = retain
        self.variableHeader = variableHeader
        self.payload = payload
    }
}
