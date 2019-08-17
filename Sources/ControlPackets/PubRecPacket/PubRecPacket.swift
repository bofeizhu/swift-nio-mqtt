//
//  PubRecPacket.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 7/27/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

/// PUBREC Packet – Publish received (QoS 2 delivery part 1)
///
/// A PUBREC packet is the response to a PUBLISH packet with QoS 2.
/// It is the second packet of the QoS 2 protocol exchange.
struct PubRecPacket: ControlPacketProtocol {

    /// Fixed Header
    let fixedHeader: FixedHeader

    /// Variable Header
    let variableHeader: VariableHeader
}
