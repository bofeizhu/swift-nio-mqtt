//
//  DisconnectPacket.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 8/20/19.
//  Copyright © 2019 Bofei Zhu. All rights reserved.
//

/// DISCONNECT Packet – Disconnect notification
///
/// The DISCONNECT packet is the final MQTT Control Packet sent from the Client or the Server.
/// It indicates the reason why the Network Connection is being closed.
/// The Client or Server MAY send a DISCONNECT packet before closing the Network Connection.
/// If the Network Connection is closed without the Client first sending a DISCONNECT packet
/// with Reason Code 0x00 (Normal disconnection) and the Connection has a Will Message,
/// the Will Message is published.
public struct DisconnectPacket: ControlPacketProtocol {
    /// Fixed Header
    let fixedHeader: FixedHeader

    /// Variable Header
    let variableHeader: VariableHeader
}
