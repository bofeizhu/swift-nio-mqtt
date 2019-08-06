//
//  PublishPacket.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 6/18/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

/// PUBLISH packet – Publish message
///
/// A PUBLISH packet is sent from a Client to a Server or from a Server to a Client to transport an Application Message.
struct PublishPacket: PayloadPacket {

    /// Fixed Header
    let fixedHeader: FixedHeader

    /// DUP Flag
    var dup: Bool {
        return ((fixedHeader.flags >> 3) & 1) == 1
    }

    /// QoS Flag
    var qos: QoS {
        let rawValue = (fixedHeader.flags >> 1) & 0b11
        guard let qos = QoS(rawValue: rawValue)
        else {
            return .malformed
        }
        return qos
    }

    /// RETAIN Flag
    var retain: Bool {
        return (fixedHeader.flags & 1) == 1
    }

    /// Variable Header
    let variableHeader: VariableHeader

    /// Payload
    let payload: DataPayload
}
