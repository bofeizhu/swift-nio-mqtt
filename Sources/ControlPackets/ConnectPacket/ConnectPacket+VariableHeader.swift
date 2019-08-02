//
//  ConnectPacket+VariableHeader.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 7/21/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

extension ConnectPacket: VariableHeaderPacket {

    /// CONNECT Variable Header
    struct VariableHeader: HasProperties {

        /// MQTT Protocol Name
        let protocolName = "MQTT"

        /// MQTT Protocol Version
        let protocolVersion: UInt8 = 5

        /// Connect Flags
        let connectFlags: ConnectFlags

        /// Keep Alive
        let keepAlive: UInt16

        /// Properties
        let properties: [Property]
    }

    /// Connect Flags
    ///
    /// The Connect Flags contains several parameters specifying the behavior of the MQTT connection.
    /// It also indicates the presence or absence of fields in the Payload.
    struct ConnectFlags: RawRepresentable {
        typealias RawValue = UInt8

        let rawValue: UInt8

        let cleanStart: Bool

        let willFlag: Bool

        let willQoS: QoS

        let willRetain: Bool

        let passwordFlag: Bool

        let userNameFlag: Bool

        init?(rawValue: UInt8) {

            let qosValue = (rawValue >> 3) & 0b11

            // The Server MUST validate that the reserved flag in the CONNECT packet is set to 0
            guard
                rawValue & 1 == 0,
                let qos = QoS(rawValue: qosValue),
                qos != .malformed
            else {
                return nil
            }

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
