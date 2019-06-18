//
//  FixedHeader.swift
//  SwiftNIOMQTT
//
//  Created by Bofei Zhu on 6/17/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

/// The last four bits in the Fixed Header contain flags specific to each MQTT Control Packet type.
typealias FixedHeaderFlags = UInt8

/// MQTT Control Packet Fixed Header
struct FixedHeader {
    
    /// MQTT Control Packet type
    let type: ControlPacketType
    
    /// MQTT Control Packet Flags
    let flags: FixedHeaderFlags
    
    /// The Remaining Length is a Variable Byte Integer that represents the number of bytes remaining within
    /// the current Control Packet, including data in the Variable Header and the Payload.
    /// The Remaining Length does not include the bytes used to encode the Remaining Length.
    /// The packet size is the total number of bytes in an MQTT Control Packet, this is equal to the length of
    /// the Fixed Header plus the Remaining Length.
    let remainingLength: VInt
}
