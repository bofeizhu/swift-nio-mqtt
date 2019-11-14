//
//  PublishPacket+VariableHeader.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 7/22/19.
//  Copyright © 2019 Bofei Zhu. All rights reserved.
//

extension PublishPacket: VariableHeaderPacket {

    /// PUBLISH Variable Header
    struct VariableHeader: HasProperties, MQTTByteRepresentable {

        /// Topic Name
        let topicName: String

        /// Packet Identifier
        let packetIdentifier: UInt16?

        /// Properties
        let properties: PropertyCollection

        var mqttByteCount: Int {
            let packetIdentifierByteCount = packetIdentifier == nil ? 0 : UInt16.byteCount

            return topicName.mqttByteCount + packetIdentifierByteCount + properties.mqttByteCount
        }
    }
}
