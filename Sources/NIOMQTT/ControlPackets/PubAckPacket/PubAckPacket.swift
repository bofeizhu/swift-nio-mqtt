//
//  PubAckPacket.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 7/22/19.
//  Copyright © 2019 Bofei Zhu. All rights reserved.
//

/// PUBACK Packet – Publish acknowledgement
///
/// A PUBACK packet is the response to a PUBLISH packet with QoS 1.
struct PubAckPacket: ControlPacketProtocol {
    /// Fixed Header
    let fixedHeader: FixedHeader

    /// Variable Header
    let variableHeader: VariableHeader

    init(variableHeader: VariableHeader) {
        fixedHeader = FixedHeader(type: .pubAck, flags: .pubAck, remainingLength: variableHeader.mqttByteCount)
        self.variableHeader = variableHeader
    }
}
