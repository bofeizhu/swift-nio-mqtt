//
//  PingReqPacket.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 6/20/19.
//  Copyright © 2019 Bofei Zhu. All rights reserved.
//

/// PINGREQ Packet – PING request
///
/// The PINGREQ packet is sent from a Client to the Server in Keep Alive processing.
///
/// - Note:
///     It can be used to:
///     * Indicate to the Server that the Client is alive in the absence of any other MQTT Control Packets
///       being sent from the Client to the Server.
///     * Request that the Server responds to confirm that it is alive.
///     * Exercise the network to indicate that the Network Connection is active.
public struct PingReqPacket: ControlPacketProtocol {
    /// The fixed header for PINGREQ packet
    let fixedHeader: FixedHeader

    public init() {
        fixedHeader = FixedHeader(type: .pingReq, remainingLength: 0)
    }
}
