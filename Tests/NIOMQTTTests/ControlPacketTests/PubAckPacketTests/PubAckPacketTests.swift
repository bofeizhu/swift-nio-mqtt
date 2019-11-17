//
//  PubAckPacketTests.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 11/16/19.
//  Copyright © 2019 Bofei Zhu. All rights reserved.
//

import XCTest

@testable import NIOMQTT

class PubAckPacketTests: XCTestCase {

    func testVariableHeaderByteCount() {
        let connectFlags = ConnectPacket.ConnectFlags(rawValue: 0)!
        let properties = PropertyCollection()

        let variableHeader = ConnectPacket.VariableHeader(
            connectFlags: connectFlags,
            keepAlive: 120,
            properties: properties)

        XCTAssertEqual(variableHeader.mqttByteCount, 11)
    }

    func testPayloadByteCount() {
        let bytes: [UInt8] = [0, 0]

        let willMessage = ConnectPacket.WillMessage(
            properties: PropertyCollection(),
            topic: "abc",
            payload: Data(bytes))

        XCTAssertEqual(willMessage.mqttByteCount, 10)

        var payload = ConnectPacket.Payload(
            clientId: "abc",
            willMessage: nil,
            username: nil,
            password: nil)

        XCTAssertEqual(payload.mqttByteCount, 5)

        payload = ConnectPacket.Payload(
            clientId: "abc",
            willMessage: willMessage,
            username: "foo",
            password: Data(bytes))

        XCTAssertEqual(payload.mqttByteCount, 24)
    }
}
