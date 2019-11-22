//
//  ConnectPacketIOTests.swift
//  NIOMQTTTests
//
//  Created by Bofei Zhu on 8/25/19.
//  Copyright © 2019 Bofei Zhu. All rights reserved.
//

import XCTest
import NIO

@testable import NIOMQTT

// swiftlint:disable force_try

final class ConnectPacketIOTests: ByteBufferTestCase {

    func testWriteConnectPacket() {
        let connectFlags = ConnectPacket.ConnectFlags(rawValue: 0)!
        let variableHeader = ConnectPacket.VariableHeader(
            connectFlags: connectFlags,
            keepAlive: 120,
            properties: PropertyCollection())

        let bytes: [UInt8] = [0, 0]

        let willMessage = ConnectPacket.WillMessage(
            properties: PropertyCollection(),
            topic: "abc",
            payload: Data(bytes))

        let payload = ConnectPacket.Payload(
            clientId: "abc",
            willMessage: willMessage,
            username: "foo",
            password: Data(bytes))

        let connectPacket = ConnectPacket(
            variableHeader: variableHeader,
            payload: payload)

        try! buffer.write(connectPacket)

        XCTAssertEqual(
            buffer.readableBytes,
            variableHeader.mqttByteCount + payload.mqttByteCount + 2)

        // TODO: Read stuff
    }
}
