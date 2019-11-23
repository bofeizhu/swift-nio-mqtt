//
//  UnsubAckPacket+VariableHeader.swift
//  MQTTCodec
//
//  Created by Bofei Zhu on 8/19/19.
//  Copyright © 2019 Bofei Zhu. All rights reserved.
//

extension UnsubAckPacket: VariableHeaderPacket {

    struct VariableHeader: HasProperties, MQTTByteRepresentable {

        let packetIdentifier: UInt16

        let properties: PropertyCollection

        var mqttByteCount: Int {
            UInt16.byteCount + properties.mqttByteCount
        }
    }
}
