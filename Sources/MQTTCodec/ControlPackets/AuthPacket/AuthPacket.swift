//
//  AuthPacket.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 8/20/19.
//  Copyright © 2019 Bofei Zhu. All rights reserved.
//

/// AUTH Packet – Authentication exchange
public struct AuthPacket: ControlPacketProtocol {
    /// Fixed Header
    let fixedHeader: FixedHeader

    /// Variable Header
    let variableHeader: VariableHeader
}
