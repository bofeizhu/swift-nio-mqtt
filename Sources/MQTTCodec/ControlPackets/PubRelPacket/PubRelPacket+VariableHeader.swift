//
//  PubRelPacket+VariableHeader.swift
//  MQTTCodec
//
//  Created by Bofei Zhu on 7/28/19.
//  Copyright © 2019 Bofei Zhu. All rights reserved.
//

extension PubRelPacket: VariableHeaderPacket {

    /// PUBREL Variable Header
    struct VariableHeader: HasProperties, MQTTByteRepresentable {

        /// Packet Identifier
        let packetIdentifier: UInt16

        /// Reason Code
        let reasonCode: ReasonCode

        /// Properties
        let properties: PropertyCollection

        var mqttByteCount: Int {
            guard !properties.isEmpty else {
                if reasonCode == .success {
                    // The Reason Code and Property Length can be omitted if the Reason Code is 0x00 (Success) and
                    // there are no Properties. In this case the PUBREL has a Remaining Length of 2.
                    return 2
                } else {
                    // If the Remaining Length is less than 4 there is no Property Length and the value of 0 is used.
                    return 3
                }
            }
            return UInt16.byteCount + ReasonCodeValue.byteCount + properties.mqttByteCount
        }
    }
}
