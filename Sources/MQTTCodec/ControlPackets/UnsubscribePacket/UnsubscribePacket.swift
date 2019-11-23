//
//  UnsubscribePacket.swift
//  MQTTCodec
//
//  Created by Bofei Zhu on 8/19/19.
//  Copyright © 2019 Bofei Zhu. All rights reserved.
//

/// UNSUBSCRIBE Packet – Unsubscribe request
public struct UnsubscribePacket: ControlPacketProtocol {

    /// Fixed Header
    let fixedHeader: FixedHeader

    /// Variable Header
    public let variableHeader: VariableHeader

    /// Payload
    public let payload: Payload

    init(variableHeader: VariableHeader, payload: Payload) {
        self.variableHeader = variableHeader
        self.payload = payload

        let remainingLength = variableHeader.mqttByteCount + payload.mqttByteCount
        fixedHeader = FixedHeader(type: .unsubscribe, remainingLength: remainingLength)
    }
}
