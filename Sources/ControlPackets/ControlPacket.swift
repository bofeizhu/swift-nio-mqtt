//
//  ControlPacket.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 7/22/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

enum ControlPacket {

    /// Connection request
    case connect(packet: ConnectPacket)

    /// Connect acknowledgment
    case connAck(packet: ConnAckPacket)

    /// Publish message
    case publish(packet: PublishPacket)

    /// Publish acknowledgment (QoS 1)
    case pubAck(packet: PubAckPacket)

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
    case pingReq(packet: PingReqPacket)

    /// PING response
    case pingResp(packet: PingRespPacket)

    /// Disconnect notification
    case disconnect

    /// Authentication exchange
    case auth
}

// MARK: - MQTT Control Packet Typealias

/// Reason Code Value
///
/// A Reason Code is a one byte unsigned value that indicates the result of an operation.
/// Reason Codes less than 0x80 indicate successful completion of an operation.
/// The normal Reason Code for success is 0. Reason Code values of 0x80 or greater indicate failure.
typealias ReasonCodeValue = UInt8
