//
//  ControlPacketProtocol.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 6/13/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

/// MQTT Control Packet Protocol
///
/// The MQTT protocol operates by exchanging a series of MQTT Control Packets in a defined way.
protocol ControlPacketProtocol {
    var fixedHeader: FixedHeader { get }
}

/// MQTT Control Packet with Variable Header
///
/// Some types of MQTT Control Packet contain a Variable Header component.
/// It resides between the Fixed Header and the Payload.
/// The content of the Variable Header varies depending on the packet type.
protocol VariableHeaderPacket: ControlPacketProtocol {
    associatedtype VariableHeader

    /// Variable Header
    var variableHeader: VariableHeader { get }
}

/// MQTT Control Packet with Payload
///
/// Some MQTT Control Packets contain a Payload as the final part of the packet.
protocol PayloadPacket: ControlPacketProtocol {
    associatedtype Payload

    /// Payload
    var payload: Payload { get }
}
