//
//  ControlPacketType.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 7/22/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

/// MQTT Control Packet Type
///
/// **Position:** byte 1, bits 7-4.
///
/// Represented as a 4-bit unsigned value, the values are listed in
/// [MQTT Control Packet types](http://docs.oasis-open.org/mqtt/mqtt/v5.0/csprd01/mqtt-v5.0-csprd01.html#_Toc489530053)
enum ControlPacketType: UInt8 {
    /// Connection request
    case connect = 1

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
