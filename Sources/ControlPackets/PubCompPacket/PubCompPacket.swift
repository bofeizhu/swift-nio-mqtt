//
//  PubCompPacket.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 7/28/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

/// PUBCOMP Packet – Publish complete (QoS 2 delivery part 3)
struct PubCompPacket: ControlPacketProtocol {

    // Reserved fixed header flags for PUBCOMP packet
    static let flags: FixedHeaderFlags = 0

    /// Fixed Header
    let fixedHeader: FixedHeader

    /// Variable Header
    let variableHeader: VariableHeader
}
