//
//  UnsubscribePacket+VariableHeader.swift
//  MQTTCodec
//
//  Created by Bofei Zhu on 8/19/19.
//  Copyright © 2019 Bofei Zhu. All rights reserved.
//

extension UnsubscribePacket: VariableHeaderPacket {

    /// UNSUBSCRIBE Variable Header
    public struct VariableHeader: HasProperties, MQTTByteRepresentable {

        /// Packet Identifier
        public let packetIdentifier: UInt16

        /// Properties
        public let properties: PropertyCollection

        var mqttByteCount: Int {
            UInt16.byteCount + properties.mqttByteCount
        }
    }
}
