//
//  ConnectPacketBuilderTests.swift
//  NIOMQTTTests
//
//  Created by Bofei Zhu on 11/16/19.
//  Copyright © 2019 Bofei Zhu. All rights reserved.
//

import XCTest
import NIO
import Foundation

@testable import NIOMQTT

class ConnectPacketBuilderTests: XCTestCase {

    var builder: ConnectPacketBuilder!

    override func setUp() {
        super.setUp()

        builder = ConnectPacketBuilder(clientId: "id")
    }

    override func tearDown() {
        builder = nil

        super.tearDown()
    }

    func testCleanStart() {
        let packet = builder.cleanStart(true).build()
        XCTAssertEqual(packet.variableHeader.connectFlags.cleanStart, true)
    }

    func testKeepAlive() {
        let packet = builder.keepAlive(30).build()
        XCTAssertEqual(packet.variableHeader.keepAlive, 30)
    }

    func testWillMessage() {
        let message = ConnectPacket.WillMessage(properties: PropertyCollection(), topic: "topic", payload: Data())
        let packet = builder.willMessage(message, willQoS: .exactlyOnce, willRetain: true).build()
        XCTAssertEqual(packet.payload.willMessage, message)
        XCTAssertEqual(packet.variableHeader.connectFlags.willQoS, .exactlyOnce)
        XCTAssertEqual(packet.variableHeader.connectFlags.willRetain, true)
    }

    func testUsername() {
        let packet = builder.username("foo").build()
        XCTAssertEqual(packet.payload.username, "foo")
    }

    func testPassword() {
        let password = "bar".data(using: .utf8)
        let packet = builder.password(password).build()
        XCTAssertEqual(packet.payload.password, password)
    }
}

extension ConnectPacket.WillMessage: Equatable {
    public static func == (lhs: ConnectPacket.WillMessage, rhs: ConnectPacket.WillMessage) -> Bool {
        return lhs.topic == rhs.topic && lhs.payload == rhs.payload
    }
}
