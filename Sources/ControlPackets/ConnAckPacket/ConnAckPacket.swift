//
//  ConnAckPacket.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 7/21/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

/// CONNACK Packet – Connect acknowledgement
///
/// The CONNACK packet is the packet sent by the Server in response to a CONNECT packet received from a Client.
struct ConnAckPacket: ControlPacketProtocol {

    /// Reserved fixed header flags for CONNACK packet
    static let flags: FixedHeaderFlags = 0

    /// Fixed Header
    let fixedHeader: FixedHeader

    /// Variable Header
    let variableHeader: VariableHeader
}
