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

// MARK: - MQTT Control Packet Typealias

/// Reason Code Value
///
/// A Reason Code is a one byte unsigned value that indicates the result of an operation.
/// Reason Codes less than 0x80 indicate successful completion of an operation.
/// The normal Reason Code for success is 0. Reason Code values of 0x80 or greater indicate failure.
typealias ReasonCodeValue = UInt8
