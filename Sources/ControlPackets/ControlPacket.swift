//
//  ControlPacket.swift
//  SwiftNIOMQTT
//
//  Created by Bofei Zhu on 6/13/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

/// A Reason Code is a one byte unsigned value that indicates the result of an operation.
/// Reason Codes less than 0x80 indicate successful completion of an operation.
/// The normal Reason Code for success is 0. Reason Code values of 0x80 or greater indicate failure.
typealias ReasonCode = UInt8

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
    case connect
    
    /// Connect acknowledgment
    case connAck
    
    /// Publish message
    case publish
    
    /// Publish acknowledgment (QoS 1)
    case pubAck
    
    /// Publish received (QoS 2 delivery part 1)
    case pubRec
    
    /// Publish release (QoS 2 delivery part 2)
    case pubRel
    
    /// Publish complete (QoS 2 delivery part 3)
    case pubComp
    
    /// Subscribe request
    case subscribe
    
    /// Subscribe acknowledgment
    case subAck
    
    /// Unsubscribe request
    case unsubscribe
    
    /// Unsubscribe acknowledgment
    case unsubAck
    
    /// PING request
    case pingReq
    
    /// PING response
    case pingResp
    
    /// Disconnect notification
    case disconnect
    
    /// Authentication exchange
    case auth
}
