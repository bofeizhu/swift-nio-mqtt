//
//  PubAckPacket+VariableHeader.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 7/22/19.
//  Copyright © 2019 Bofei Zhu. All rights reserved.
//

extension PubAckPacket: VariableHeaderPacket {
    /// PUBACK Variable Header
    struct VariableHeader: HasProperties, MQTTByteRepresentable {
        /// Packet Identifier
        let packetIdentifier: UInt16

        /// PUBACK Reason Code
        let reasonCode: ReasonCode

        /// Properties
        let properties: PropertyCollection

        var mqttByteCount: Int {
            guard !properties.isEmpty || reasonCode != .success else {
                // The Reason Code and Property Length can be omitted if the Reason Code is 0x00 (Success) and
                // there are no Properties. In this case the PUBACK has a Remaining Length of 2.
                return 2
            }
            return UInt16.byteCount + ReasonCodeValue.byteCount + properties.mqttByteCount
        }
    }
}
