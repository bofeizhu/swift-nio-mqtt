//
//  ConnectPacket.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 6/18/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

/// CONNECT Packet – Connection request
///
/// - Note:
///     After a Network Connection is established by a Client to a Server,
///     the first packet sent from the Client to the Server MUST be a CONNECT packet.
///     A Client can only send the CONNECT packet once over a Network Connection.
///     The Server MUST process a second CONNECT packet sent from a Client as a Protocol Error
///     and close the Network Connection
struct ConnectPacket: ControlPacketProtocol {

    /// Fixed Header
    let fixedHeader: FixedHeader

    /// Variable Header
    let variableHeader: VariableHeader

    /// Payload
    let payload: Payload
}
