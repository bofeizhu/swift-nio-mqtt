//
//  SubscribePacket+VariableHeader.swift
//  MQTTCodec
//
//  Created by Bofei Zhu on 7/28/19.
//  Copyright © 2019 Bofei Zhu. All rights reserved.
//

extension SubscribePacket: VariableHeaderPacket {

    /// SUBSCRIBE Variable Header
    public struct VariableHeader: HasProperties, MQTTByteRepresentable {

        /// Packet Identifier
        let packetIdentifier: UInt16

        /// Properties
        let properties: PropertyCollection

        var mqttByteCount: Int {
            UInt16.byteCount + properties.mqttByteCount
        }
    }
}
