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

        // MARK: MQTT Procotol

        /// Protocol Name
        let protocolName = "MQTT"

        /// Protocol Version
        let protocolVersion: UInt8 = 5

        // MARK: Connect Flags

        /// This bit specifies whether the Connection starts a new Session or is a continuation of an existing Session.
        let cleanStart: Bool

        let willFlag: Bool
        let willQoS: QoS
        let willRetain: Bool
        let userNameFlag: Bool

        // MARK: Keep Alive

        /// Keep Alive
        let keepAlive: UInt16

        // MARK: Properties

        /// Properties
        let properties: [Property]
    }
}
