//
//  PubCompPacketIOTests.swift
//  NIOMQTTTests
//
//  Created by Bofei Zhu on 11/16/19.
//  Copyright © 2019 Bofei Zhu. All rights reserved.
//

import XCTest
import NIO

@testable import NIOMQTT

// swiftlint:disable force_try

class PubCompPacketIOTests: ByteBufferTestCase {

    func testReadWhenReasonCodeIsSuccessAndPacketHasNoProperty() {
        let fixedHeader = FixedHeader(type: .pubComp, remainingLength: 2)
        let packetIdentifier: UInt16 = 23

        buffer.writeInteger(packetIdentifier)

        let packet = try! buffer.readPubCompPacket(with: fixedHeader)
        XCTAssertEqual(packet.variableHeader.packetIdentifier, 23)
        XCTAssertEqual(packet.variableHeader.reasonCode, .success)
        XCTAssertTrue(packet.variableHeader.properties.isEmpty)
    }

    func testReadWhenReasonCodeIsNotSuccessAndPacketHasNoProperty() {
        let fixedHeader = FixedHeader(type: .pubComp, remainingLength: 3)
        let packetIdentifier: UInt16 = 23

        buffer.writeInteger(packetIdentifier)
        buffer.writeByte(PubCompPacket.ReasonCode.packetIdentifierNotFound.rawValue)

        let packet = try! buffer.readPubCompPacket(with: fixedHeader)
        XCTAssertEqual(packet.variableHeader.packetIdentifier, 23)
        XCTAssertEqual(packet.variableHeader.reasonCode, .packetIdentifierNotFound)
        XCTAssertTrue(packet.variableHeader.properties.isEmpty)

        XCTAssertEqual(buffer.readableBytes, 0)
    }

    func testReadWhenPacketHasProperties() {
        var properties = PropertyCollection()
        properties.append(.payloadFormatIndicator(true))

        let fixedHeader = FixedHeader(type: .pubComp, remainingLength: 6)
        let packetIdentifier: UInt16 = 23

        buffer.writeInteger(packetIdentifier)
        buffer.writeByte(PubCompPacket.ReasonCode.packetIdentifierNotFound.rawValue)
        try! buffer.write(properties)

        let packet = try! buffer.readPubCompPacket(with: fixedHeader)
        XCTAssertEqual(packet.variableHeader.packetIdentifier, 23)
        XCTAssertEqual(packet.variableHeader.reasonCode, .packetIdentifierNotFound)
        XCTAssertEqual(packet.variableHeader.properties.count, 1)

        XCTAssertEqual(buffer.readableBytes, 0)
    }

    func testWriteWhenReasonCodeIsSuccessAndPacketHasNoProperty() {
        let variableHeader = PubCompPacket.VariableHeader(
            packetIdentifier: .zero,
            reasonCode: .success,
            properties: PropertyCollection())

        let packet = PubCompPacket(variableHeader: variableHeader)
        try! buffer.write(packet)

        // The Reason Code and Property Length can be omitted if the Reason Code is 0x00 (Success) and
        // there are no Properties. In this case the PubComp has a Remaining Length of 2.
        XCTAssertEqual(buffer.readableBytes, 4)

        let fixedHeader = try! buffer.readFixedHeader()!
        let expectedFixedHeader = FixedHeader(type: .pubComp, remainingLength: 2)

        XCTAssertEqual(fixedHeader, expectedFixedHeader)

        let packetIdentifier: UInt16 = buffer.readInteger()!

        XCTAssertEqual(packetIdentifier, .zero)

        XCTAssertEqual(buffer.readableBytes, 0)
    }

    func testWriteWhenReasonCodeIsNotSuccessAndPacketHasNoProperty() {
        let variableHeader = PubCompPacket.VariableHeader(
            packetIdentifier: .zero,
            reasonCode: .packetIdentifierNotFound,
            properties: PropertyCollection())

        let packet = PubCompPacket(variableHeader: variableHeader)
        try! buffer.write(packet)

        // The Reason Code and Property Length can be omitted if the Reason Code is 0x00 (Success) and
        // there are no Properties. In this case the PubComp has a Remaining Length of 2.
        XCTAssertEqual(buffer.readableBytes, 5)

        let fixedHeader = try! buffer.readFixedHeader()!
        let expectedFixedHeader = FixedHeader(type: .pubComp, remainingLength: 3)

        XCTAssertEqual(fixedHeader, expectedFixedHeader)

        let packetIdentifier: UInt16 = buffer.readInteger()!

        XCTAssertEqual(packetIdentifier, .zero)

        let reasonCodeByte = buffer.readByte()
        XCTAssertEqual(reasonCodeByte, PubCompPacket.ReasonCode.packetIdentifierNotFound.rawValue)

        XCTAssertEqual(buffer.readableBytes, 0)
    }

    func testWriteWhenPacketHasProperties() {
        var properties = PropertyCollection()
        properties.append(.payloadFormatIndicator(true))

        let variableHeader = PubCompPacket.VariableHeader(
            packetIdentifier: .zero,
            reasonCode: .packetIdentifierNotFound,
            properties: properties)

        let packet = PubCompPacket(variableHeader: variableHeader)
        try! buffer.write(packet)

        // The Reason Code and Property Length can be omitted if the Reason Code is 0x00 (Success) and
        // there are no Properties. In this case the PubComp has a Remaining Length of 2.
        XCTAssertEqual(buffer.readableBytes, 8)

        let fixedHeader = try! buffer.readFixedHeader()!
        let expectedFixedHeader = FixedHeader(type: .pubComp, remainingLength: 6)

        XCTAssertEqual(fixedHeader, expectedFixedHeader)

        let packetIdentifier: UInt16 = buffer.readInteger()!

        XCTAssertEqual(packetIdentifier, .zero)

        let reasonCodeByte = buffer.readByte()
        XCTAssertEqual(reasonCodeByte, PubCompPacket.ReasonCode.packetIdentifierNotFound.rawValue)

        let _ = try! buffer.readProperties()

        XCTAssertEqual(buffer.readableBytes, 0)
    }
}
