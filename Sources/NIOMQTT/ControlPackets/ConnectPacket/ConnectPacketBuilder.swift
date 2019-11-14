//
//  ConnectPacketBuilder.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 10/29/19.
//  Copyright © 2019 Bofei Zhu. All rights reserved.
//

import struct Foundation.Data

final class ConnectPacketBuilder {

    private var clientId: String

    private var cleanStart: Bool = false

    private var keepAlive: UInt16 = 0

    private var willMessage: ConnectPacket.WillMessage?

    private var willQoS: QoS = .atMostOnce

    private var willRetain: Bool = false

    private var username: String?

    private var password: Data?

    init(clientId: String) {
        self.clientId = clientId
    }

    func cleanStart(_ cleanStart: Bool) -> ConnectPacketBuilder {
        self.cleanStart = cleanStart
        return self
    }

    func keepAlive(_ keepAlive: UInt16) -> ConnectPacketBuilder {
        self.keepAlive = keepAlive
        return self
    }

    func willMessage(
        _ willMessage: ConnectPacket.WillMessage?,
        willQoS: QoS = .atMostOnce,
        willRetain: Bool = false
    ) -> ConnectPacketBuilder {
        self.willMessage = willMessage
        self.willQoS = willQoS
        self.willRetain = willRetain
        return self
    }

    func username(_ username: String?) -> ConnectPacketBuilder {
        self.username = username
        return self
    }

    func password(_ password: Data?) -> ConnectPacketBuilder {
        self.password = password
        return self
    }

    func build() -> ConnectPacket {
        let connectFlags = ConnectPacket.ConnectFlags(
            cleanStart: cleanStart,
            willFlag: willMessage != nil,
            willQoS: willQoS,
            willRetain: willRetain,
            passwordFlag: password != nil,
            userNameFlag: username != nil)

        let variableHeader = ConnectPacket.VariableHeader(
            connectFlags: connectFlags,
            keepAlive: keepAlive,
            properties: PropertyCollection())

        let payload = ConnectPacket.Payload(
            clientId: clientId,
            willMessage: willMessage,
            username: username,
            password: password)

        return ConnectPacket(variableHeader: variableHeader, payload: payload)
    }
}
