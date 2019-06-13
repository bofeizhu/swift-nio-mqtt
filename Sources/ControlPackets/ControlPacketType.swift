//
//  ControlPacketType.swift
//  SwiftNIOMQTT
//
//  Created by Bofei Zhu on 6/13/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//


/// MQTT Control Packet Type
///
/// **Position:** byte 1, bits 7-4.
///
/// Represented as a 4-bit unsigned value, the values are listed in
/// [Table 2‑1 MQTT Control Packet types](http://docs.oasis-open.org/mqtt/mqtt/v5.0/csprd01/mqtt-v5.0-csprd01.html#_Toc489530053)
enum ControlPacketType: UInt8 {
    
    /// Reserved
    case reserved = 0
    
    /// Connection request
    case connect = 1
    
    /// Connect acknowledgment
    case connAck = 2
    
    /// Publish message
    case publish = 3
    
    /// Publish acknowledgment (QoS 1)
    case pubAck = 4
    
    /// Publish received (QoS 2 delivery part 1)
    case pubRec = 5
    
    /// Publish release (QoS 2 delivery part 2)
    case pubRel = 6
    
    /// Publish complete (QoS 2 delivery part 3)
    case pubComp = 7
    
    /// Subscribe request
    case subscribe = 8
    
    /// Subscribe acknowledgment
    case subAck = 9
    
    /// Unsubscribe request
    case unsubscribe = 10
    
    /// Unsubscribe acknowledgment
    case unsubAck = 11
    
    /// PING request
    case pingReq = 12
    
    /// PING response
    case pingResp = 13
    
    /// Disconnect notification
    case disconnect = 14
    
    /// Authentication exchange
    case auth = 15
}
