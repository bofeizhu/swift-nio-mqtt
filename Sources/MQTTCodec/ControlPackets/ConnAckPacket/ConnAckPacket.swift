//
//  ConnAckPacket.swift
//  MQTTCodec
//
//  Created by Bofei Zhu on 7/21/19.
//  Copyright © 2019 Bofei Zhu. All rights reserved.
//

/// CONNACK Packet – Connect acknowledgement
///
/// The CONNACK packet is the packet sent by the Server in response to a CONNECT packet received from a Client.
public struct ConnAckPacket: ControlPacketProtocol {
    /// Fixed Header
    let fixedHeader: FixedHeader

    /// Variable Header
    public let variableHeader: VariableHeader
}
