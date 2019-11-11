//
//  ConnAckPacket+VariableHeader.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 7/21/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

extension ConnAckPacket: VariableHeaderPacket {
    /// CONNACK Variable Header
    struct VariableHeader: HasProperties, MQTTByteRepresentable {
        /// Session Present Flag
        ///
        /// The Session Present flag informs the Client whether the Server is using Session State
        /// from a previous connection for this ClientID.
        /// This allows the Client and Server to have a consistent view of the Session State.
        /// - Note:
        ///     Byte 1 of ConnAck Packet is the "Connect Acknowledge Flags".
        ///     Bit 0 is the Session Present Flag. Bits 7-1 are reserved and MUST be set to 0.
        let sessionPresentFlag: Bool

        /// Connect Reason Code
        let connectReasonCode: ConnectPacket.ReasonCode

        /// Properties
        let properties: PropertyCollection

        var mqttByteCount: Int {
            UInt8.byteCount + ReasonCodeValue.byteCount + properties.mqttByteCount
        }
    }
}
