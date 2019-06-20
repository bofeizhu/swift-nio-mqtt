//
//  ConnectPacket.swift
//  SwiftNIOMQTT
//
//  Created by Bofei Zhu on 6/18/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

/// CONNECT Packet – Connection Request
///
/// - Note:
///     After a Network Connection is established by a Client to a Server,
///     the first packet sent from the Client to the Server MUST be a CONNECT packet.
///     A Client can only send the CONNECT packet once over a Network Connection.
///     The Server MUST process a second CONNECT packet sent from a Client as a Protocol Error
///     and close the Network Connection
struct ConnectPacket: VariableHeaderPacket, PayloadPacket {
    typealias VariableHeader = ConnectVariableHeader
    typealias Payload = ConnectPayload
    
    /// Reserved fixed header flags for CONNECT packet
    static let flags: FixedHeaderFlags = 0
    
    let fixedHeader: FixedHeader
    var variableHeader: ConnectVariableHeader
    var payload: ConnectPayload
}

/// The Variable Header for CONNECT Packet
struct ConnectVariableHeader: PropertyProtocol {

    // MARK: MQTT Procotol
    
    let protocolName = "MQTT"
    let protocolVersion: UInt8 = 5
    
    // MARK: Connect Flags
    
    /// This bit specifies whether the Connection starts a new Session or is a continuation of an existing Session.
    let cleanStart: Bool
    let willFlag: Bool
    let willQoS: QoS
    let willRetain: Bool
    let userNameFlag: Bool
    
    // MARK: Keep Alive
    let keepAlive: UInt16
    
    // MARK: Properties
    
    // Properties
    let properties: [Property]
}


/// The Payload for the CONNECT Packet
struct ConnectPayload {
    
    // MARK: 
}
