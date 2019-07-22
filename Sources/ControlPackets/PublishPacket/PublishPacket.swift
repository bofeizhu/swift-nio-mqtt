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
struct PublishPacket: ControlPacket, PayloadPacket {

    /// Fixed Header
    let fixedHeader: FixedHeader

    /// Variable Header
    let variableHeader: VariableHeader

    /// Payload
    let payload: DataPayload

    /// DUP Flag
    var dup: Bool {
        return ((fixedHeader.flags & 0b1000) >> 3) == 1
    }

    /// QoS Flag
    var qos: QoS {
        let rawValue = (fixedHeader.flags & 0b110) >> 1
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
}
