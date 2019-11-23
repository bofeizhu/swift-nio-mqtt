//
//  UnsubAckPacket.swift
//  MQTTCodec
//
//  Created by Bofei Zhu on 8/19/19.
//  Copyright © 2019 Bofei Zhu. All rights reserved.
//

public struct UnsubAckPacket: ControlPacketProtocol {

    /// Fixed Header
    let fixedHeader: FixedHeader

    /// Variable Header
    let variableHeader: VariableHeader

    /// Payload
    let payload: Payload
}
