//
//  PublishPacket+VariableHeader.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 7/22/19.
//  Copyright © 2019 Bofei Zhu. All rights reserved.
//

extension PublishPacket: VariableHeaderPacket {

    /// PUBLISH Variable Header
    public struct VariableHeader: HasProperties, MQTTByteRepresentable {

        /// Topic Name
        public let topicName: String

        /// Packet Identifier
        public let packetIdentifier: UInt16?

        /// Properties
        public let properties: PropertyCollection

        var mqttByteCount: Int {
            let packetIdentifierByteCount = packetIdentifier == nil ? 0 : UInt16.byteCount

            return topicName.mqttByteCount + packetIdentifierByteCount + properties.mqttByteCount
        }
    }
}
