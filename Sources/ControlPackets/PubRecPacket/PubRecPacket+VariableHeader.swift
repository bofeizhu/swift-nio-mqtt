//
//  PubRecPacket+VariableHeader.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 7/28/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

extension PubRecPacket: VariableHeaderPacket {

    /// PUBREC Variable Header
    struct VariableHeader: HasProperties, MQTTByteRepresentable {

        /// Packet Identifier
        let packetIdentifier: UInt16

        /// Reason Code
        let reasonCode: ReasonCode

        /// Properties
        let properties: PropertyCollection

        var mqttByteCount: Int {
            UInt16.byteCount + ReasonCodeValue.byteCount + properties.mqttByteCount
        }
    }
}
