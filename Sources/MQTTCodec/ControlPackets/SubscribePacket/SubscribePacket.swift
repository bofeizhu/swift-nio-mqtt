//
//  SubscribePacket.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 7/28/19.
//  Copyright © 2019 Bofei Zhu. All rights reserved.
//

/// SUBSCRIBE Packet – Subscribe request
///
/// The SUBSCRIBE packet is sent from the Client to the Server to create one or more Subscriptions.
/// Each Subscription registers a Client’s interest in one or more Topics.
/// The Server sends PUBLISH packets to the Client to forward Application Messages
/// that were published to Topics that match these Subscriptions.
/// The SUBSCRIBE packet also specifies (for each Subscription) the maximum QoS with
/// which the Server can send Application Messages to the Client.
public struct SubscribePacket: ControlPacketProtocol {

    /// Fixed Header
    let fixedHeader: FixedHeader

    /// Variable Header
    public let variableHeader: VariableHeader

    /// Payload
    public let payload: Payload

    init(variableHeader: VariableHeader, payload: Payload) {
        let remainingLength = variableHeader.mqttByteCount + payload.mqttByteCount
        fixedHeader = FixedHeader(type: .subscribe, remainingLength: remainingLength)

        self.variableHeader = variableHeader
        self.payload = payload
    }
}
