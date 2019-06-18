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
}
