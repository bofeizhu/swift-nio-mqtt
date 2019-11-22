//
//  PubRelPacket.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 7/28/19.
//  Copyright © 2019 Bofei Zhu. All rights reserved.
//

/// PUBREL Packet – Publish release (QoS 2 delivery part 2)
///
/// A PUBREL packet is the response to a PUBREC packet. It is the third packet of the QoS 2 protocol exchange.
public struct PubRelPacket: ControlPacketProtocol {

    /// Fixed Header
    let fixedHeader: FixedHeader

    /// Variable Header
    let variableHeader: VariableHeader

    init(variableHeader: VariableHeader) {
        fixedHeader = FixedHeader(type: .pubRel, flags: .pubRel, remainingLength: variableHeader.mqttByteCount)
        self.variableHeader = variableHeader
    }
}
