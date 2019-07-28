//
//  PubRecPacket.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 7/27/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

/// PUBREC Packet – Publish received (QoS 2 delivery part 1)
struct PubRecPacket: ControlPacketProtocol {

    // Reserved fixed header flags for PUBREC packet
    static let flags: FixedHeaderFlags = 0

    /// Fixed Header
    let fixedHeader: FixedHeader

    /// Variable Header
    let variableHeader: VariableHeader
}
