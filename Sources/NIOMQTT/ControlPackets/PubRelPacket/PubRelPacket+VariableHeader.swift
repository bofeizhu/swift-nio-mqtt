//
//  PubRelPacket+VariableHeader.swift
//  NIOMQTT
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
            UInt16.byteCount + ReasonCodeValue.byteCount + properties.mqttByteCount
        }
    }
}
