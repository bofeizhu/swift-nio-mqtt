//
//  PingRespPacket.swift
//  MQTTCodec
//
//  Created by Bofei Zhu on 6/20/19.
//  Copyright © 2019 Bofei Zhu. All rights reserved.
//

/// PINGRESP Packet – PING response
///
/// A PINGRESP Packet is sent by the Server to the Client in response to a PINGREQ packet.
/// It indicates that the Server is alive.
public struct PingRespPacket: ControlPacketProtocol {
    /// The fixed header for PINGRESP packet
    let fixedHeader: FixedHeader
}
