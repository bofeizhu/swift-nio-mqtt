//
//  ConnectPacket+VariableHeader.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 7/21/19.
//  Copyright © 2019 Bofei Zhu. All rights reserved.
//

extension ConnectPacket: VariableHeaderPacket {
    /// CONNECT packet Variable Header
    struct VariableHeader: HasProperties, MQTTByteRepresentable {
        /// MQTT Protocol Name
        let protocolName = "MQTT"

        /// MQTT Protocol Version
        let protocolVersion: UInt8 = 5

        /// Connect Flags
        let connectFlags: ConnectFlags

        /// Keep Alive
        let keepAlive: UInt16

        /// Properties
        let properties: PropertyCollection

        var mqttByteCount: Int {
            protocolName.mqttByteCount +
                UInt8.byteCount +
                UInt8.byteCount +
                UInt16.byteCount +
                properties.mqttByteCount
        }
    }

    /// Connect Flags
    ///
    /// The Connect Flags contains several parameters specifying the behavior of the MQTT connection.
    /// It also indicates the presence or absence of fields in the Payload.
    struct ConnectFlags: RawRepresentable {
        typealias RawValue = UInt8

        let cleanStart: Bool

        let willFlag: Bool

        let willQoS: QoS

        let willRetain: Bool

        let passwordFlag: Bool

        let userNameFlag: Bool

        let rawValue: UInt8

        init(
            cleanStart: Bool,
            willFlag: Bool,
            willQoS: QoS,
            willRetain: Bool,
            passwordFlag: Bool,
            userNameFlag: Bool
        ) {
            self.cleanStart = cleanStart
            self.willFlag = willFlag

            // If the Will Flag is set to false, then the Will QoS MUST be set to at most once delivery.
            self.willQoS = willFlag ? willQoS : .atMostOnce

            // If the Will Flag is set to false, then Will Retain MUST be set to false.
            self.willRetain = willFlag ? willRetain : false

            self.passwordFlag = passwordFlag
            self.userNameFlag = userNameFlag

            var rawValue: UInt8 = 0
            rawValue |= (cleanStart ? 1 : 0) << 1
            rawValue |= (willFlag ? 1 : 0) << 2
            rawValue |= self.willQoS.rawValue << 3
            rawValue |= (self.willRetain ? 1 : 0) << 5
            rawValue |= (passwordFlag ? 1 : 0) << 6
            rawValue |= (userNameFlag ? 1 : 0) << 7

            self.rawValue = rawValue
        }

        init?(rawValue: UInt8) {
            let qosValue = (rawValue >> 3) & 0b11

            // The Server MUST validate that the reserved flag in the CONNECT packet is set to 0.
            guard
                rawValue & 1 == 0,
                let qos = QoS(rawValue: qosValue)
            else { return nil }

            cleanStart = ((rawValue >> 1) & 1) == 1
            willFlag = ((rawValue >> 2) & 1) == 1
            willQoS = qos
            willRetain = ((rawValue >> 5) & 1) == 1
            passwordFlag = ((rawValue >> 6) & 1) == 1
            userNameFlag = ((rawValue >> 7) & 1) == 1

            self.rawValue = rawValue
        }
    }
}
