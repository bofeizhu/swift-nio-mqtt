//
//  UnsubscribePacket.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 8/19/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

/// UNSUBSCRIBE Packet – Unsubscribe request
struct UnsubscribePacket: ControlPacketProtocol {

    /// Fixed Header
    let fixedHeader: FixedHeader

    /// Variable Header
    let variableHeader: VariableHeader

    /// Payload
    let payload: Payload

    init(variableHeader: VariableHeader, payload: Payload) {
        self.variableHeader = variableHeader
        self.payload = payload

        let remainingLength = variableHeader.mqttByteCount + payload.mqttByteCount
        fixedHeader = FixedHeader(type: .unsubscribe, remainingLength: remainingLength)
    }
}
