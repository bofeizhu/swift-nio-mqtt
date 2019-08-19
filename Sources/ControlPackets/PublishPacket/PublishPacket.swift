//
//  PublishPacket.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 6/18/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

/// PUBLISH packet – Publish message
///
/// A PUBLISH packet is sent from a Client to a Server or from a Server to a Client to
/// transport an Application Message.
struct PublishPacket: PayloadPacket {

    /// Fixed Header
    let fixedHeader: FixedHeader

    /// DUP Flag
    let dup: Bool

    /// QoS Flag
    let qos: QoS

    /// RETAIN Flag
    let retain: Bool

    /// Variable Header
    let variableHeader: VariableHeader

    /// Payload
    let payload: DataPayload

    init?(fixedHeader: FixedHeader, variableHeader: VariableHeader, payload: DataPayload) {

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
}
