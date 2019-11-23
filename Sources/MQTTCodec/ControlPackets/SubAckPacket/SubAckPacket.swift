//
//  SubAckPacket.swift
//  MQTTCodec
//
//  Created by Bofei Zhu on 8/19/19.
//  Copyright © 2019 Bofei Zhu. All rights reserved.
//

/// SUBACK Packet – Subscribe acknowledgement
///
/// A SUBACK packet is sent by the Server to the Client to confirm receipt and processing of a SUBSCRIBE packet.
public struct SubAckPacket: ControlPacketProtocol {

    /// Fixed Header
    let fixedHeader: FixedHeader

    /// Variable Header
    let variableHeader: VariableHeader

    /// Payload
    let payload: Payload
}
