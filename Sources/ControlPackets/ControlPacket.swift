//
//  ControlPacket.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 6/13/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

// MARK: - MQTT Control Packet Procotols

/// MQTT Control Packet
///
/// The MQTT protocol operates by exchanging a series of MQTT Control Packets in a defined way.
protocol ControlPacket {
    var fixedHeader: FixedHeader { get }
}

/// MQTT Control Packet with Variable Header
///
/// Some types of MQTT Control Packet contain a Variable Header component.
/// It resides between the Fixed Header and the Payload.
/// The content of the Variable Header varies depending on the packet type.
protocol VariableHeaderPacket: ControlPacket {
    associatedtype VariableHeader

    /// Variable Header
    var variableHeader: VariableHeader { get }
}

/// MQTT Control Packet with Payload
///
/// Some MQTT Control Packets contain a Payload as the final part of the packet.
protocol PayloadPacket: ControlPacket {
    associatedtype Payload

    /// Payload
    var payload: Payload { get }
}

// MARK: - MQTT Control Packet Type

/// MQTT Control Packet Type
///
/// **Position:** byte 1, bits 7-4.
///
/// Represented as a 4-bit unsigned value, the values are listed in
/// [MQTT Control Packet types](http://docs.oasis-open.org/mqtt/mqtt/v5.0/csprd01/mqtt-v5.0-csprd01.html#_Toc489530053)
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

    func validate(_ flags: FixedHeaderFlags) -> Bool {
        switch self {
        case .connect:
            return flags == ConnectPacket.flags
        default:
            // TODO: Fill the missing cases
            return false
        }
    }
}

// MARK: - MQTT Control Packet Typealias

/// A Reason Code is a one byte unsigned value that indicates the result of an operation.
/// Reason Codes less than 0x80 indicate successful completion of an operation.
/// The normal Reason Code for success is 0. Reason Code values of 0x80 or greater indicate failure.
typealias ReasonCode = UInt8
