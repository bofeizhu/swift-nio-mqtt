//
//  PubAckPacketIOTests.swift
//  NIOMQTTTests
//
//  Created by Bofei Zhu on 11/16/19.
//  Copyright © 2019 Bofei Zhu. All rights reserved.
//

import XCTest
import NIO

@testable import NIOMQTT

// swiftlint:disable force_try

class PubAckPacketIOTests: ByteBufferTestCase {

    func testWriteWhenReasonCodeIsSuccessAndPacketHasNoProperty() {
        let variableHeader = PubAckPacket.VariableHeader(
            packetIdentifier: .zero,
            reasonCode: .success,
            properties: PropertyCollection())

        let packet = PubAckPacket(variableHeader: variableHeader)
        try! buffer.write(packet)

        // The Reason Code and Property Length can be omitted if the Reason Code is 0x00 (Success) and
        // there are no Properties. In this case the PUBACK has a Remaining Length of 2.
        XCTAssertEqual(buffer.readableBytes, 4)

        let fixedHeader = try! buffer.readFixedHeader()!
        let expectedFixedHeader = FixedHeader(type: .pubAck, remainingLength: 2)

        XCTAssertEqual(fixedHeader, expectedFixedHeader)

        let packetIdentifier: UInt16 = buffer.readInteger()!

        XCTAssertEqual(packetIdentifier, .zero)

        XCTAssertEqual(buffer.readableBytes, 0)
    }

    func testWriteWhenReasonCodeIsNotSuccessAndPacketHasNoProperty() {
        let variableHeader = PubAckPacket.VariableHeader(
            packetIdentifier: .zero,
            reasonCode: .implementationSpecificError,
            properties: PropertyCollection())

        let packet = PubAckPacket(variableHeader: variableHeader)
        try! buffer.write(packet)

        // The Reason Code and Property Length can be omitted if the Reason Code is 0x00 (Success) and
        // there are no Properties. In this case the PUBACK has a Remaining Length of 2.
        XCTAssertEqual(buffer.readableBytes, 5)

        let fixedHeader = try! buffer.readFixedHeader()!
        let expectedFixedHeader = FixedHeader(type: .pubAck, remainingLength: 3)

        XCTAssertEqual(fixedHeader, expectedFixedHeader)

        let packetIdentifier: UInt16 = buffer.readInteger()!

        XCTAssertEqual(packetIdentifier, .zero)

        let reasonCodeByte = buffer.readByte()
        XCTAssertEqual(reasonCodeByte, PubAckPacket.ReasonCode.implementationSpecificError.rawValue)

        XCTAssertEqual(buffer.readableBytes, 0)
    }

    func testWriteWhenPacketHasProperties() {
        var properties = PropertyCollection()
        properties.append(.payloadFormatIndicator(true))

        let variableHeader = PubAckPacket.VariableHeader(
            packetIdentifier: .zero,
            reasonCode: .implementationSpecificError,
            properties: properties)

        let packet = PubAckPacket(variableHeader: variableHeader)
        try! buffer.write(packet)

        // The Reason Code and Property Length can be omitted if the Reason Code is 0x00 (Success) and
        // there are no Properties. In this case the PUBACK has a Remaining Length of 2.
        XCTAssertEqual(buffer.readableBytes, 8)

        let fixedHeader = try! buffer.readFixedHeader()!
        let expectedFixedHeader = FixedHeader(type: .pubAck, remainingLength: 6)

        XCTAssertEqual(fixedHeader, expectedFixedHeader)

        let packetIdentifier: UInt16 = buffer.readInteger()!

        XCTAssertEqual(packetIdentifier, .zero)

        let reasonCodeByte = buffer.readByte()
        XCTAssertEqual(reasonCodeByte, PubAckPacket.ReasonCode.implementationSpecificError.rawValue)

        let _ = try! buffer.readProperties()

        XCTAssertEqual(buffer.readableBytes, 0)
    }
}
