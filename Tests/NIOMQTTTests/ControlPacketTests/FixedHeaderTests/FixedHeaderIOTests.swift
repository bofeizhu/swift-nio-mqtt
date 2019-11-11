//
//  FixedHeaderIOTests.swift
//  NIOMQTT
//
//  Created by Elian Imlay-Maire on 9/16/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

import XCTest
import NIO

@testable import NIOMQTT

// swiftlint:disable force_try function_body_length
class FixedHeaderIOTests: ByteBufferTestCase {

    func testRead() {
        var bytes: [UInt8] = [0b00010000, 0]
        buffer.writeBytes(bytes)
        var fixedHeader = try! buffer.readFixedHeader()!
        var expectedFixedHeader = FixedHeader(type: .connect, remainingLength: .zero)
        XCTAssertEqual(fixedHeader, expectedFixedHeader)

        bytes = [0b00100000, 0]
        buffer.writeBytes(bytes)
        fixedHeader = try! buffer.readFixedHeader()!
        expectedFixedHeader = FixedHeader(type: .connAck, remainingLength: .zero)
        XCTAssertEqual(fixedHeader, expectedFixedHeader)

        bytes = [0b00110011, 0]
        buffer.writeBytes(bytes)
        fixedHeader = try! buffer.readFixedHeader()!
        expectedFixedHeader = FixedHeader(
            type: .publish,
            flags: .publish(dup: false, qos: .atLeastOnce, retain: true),
            remainingLength: .zero)
        XCTAssertEqual(fixedHeader, expectedFixedHeader)

        bytes = [0b01000000, 0]
        buffer.writeBytes(bytes)
        fixedHeader = try! buffer.readFixedHeader()!
        expectedFixedHeader = FixedHeader(type: .pubAck, remainingLength: .zero)
        XCTAssertEqual(fixedHeader, expectedFixedHeader)

        bytes = [0b01010000, 0]
        buffer.writeBytes(bytes)
        fixedHeader = try! buffer.readFixedHeader()!
        expectedFixedHeader = FixedHeader(type: .pubRec, remainingLength: .zero)
        XCTAssertEqual(fixedHeader, expectedFixedHeader)

        bytes = [0b01100010, 0]
        buffer.writeBytes(bytes)
        fixedHeader = try! buffer.readFixedHeader()!
        expectedFixedHeader = FixedHeader(type: .pubRel, remainingLength: .zero)
        XCTAssertEqual(fixedHeader, expectedFixedHeader)

        bytes = [0b01110000, 0]
        buffer.writeBytes(bytes)
        fixedHeader = try! buffer.readFixedHeader()!
        expectedFixedHeader = FixedHeader(type: .pubComp, remainingLength: .zero)
        XCTAssertEqual(fixedHeader, expectedFixedHeader)

        bytes = [0b10000010, 0]
        buffer.writeBytes(bytes)
        fixedHeader = try! buffer.readFixedHeader()!
        expectedFixedHeader = FixedHeader(type: .subscribe, remainingLength: .zero)
        XCTAssertEqual(fixedHeader, expectedFixedHeader)

        bytes = [0b10010000, 0]
        buffer.writeBytes(bytes)
        fixedHeader = try! buffer.readFixedHeader()!
        expectedFixedHeader = FixedHeader(type: .subAck, remainingLength: .zero)
        XCTAssertEqual(fixedHeader, expectedFixedHeader)

        bytes = [0b10100010, 0]
        buffer.writeBytes(bytes)
        fixedHeader = try! buffer.readFixedHeader()!
        expectedFixedHeader = FixedHeader(type: .unsubscribe, remainingLength: .zero)
        XCTAssertEqual(fixedHeader, expectedFixedHeader)

        bytes = [0b10110000, 0]
        buffer.writeBytes(bytes)
        fixedHeader = try! buffer.readFixedHeader()!
        expectedFixedHeader = FixedHeader(type: .unsubAck, remainingLength: .zero)
        XCTAssertEqual(fixedHeader, expectedFixedHeader)

        bytes = [0b11000000, 0]
        buffer.writeBytes(bytes)
        fixedHeader = try! buffer.readFixedHeader()!
        expectedFixedHeader = FixedHeader(type: .pingReq, remainingLength: .zero)
        XCTAssertEqual(fixedHeader, expectedFixedHeader)

        bytes = [0b11010000, 0]
        buffer.writeBytes(bytes)
        fixedHeader = try! buffer.readFixedHeader()!
        expectedFixedHeader = FixedHeader(type: .pingResp, remainingLength: .zero)
        XCTAssertEqual(fixedHeader, expectedFixedHeader)

        bytes = [0b11100000, 0]
        buffer.writeBytes(bytes)
        fixedHeader = try! buffer.readFixedHeader()!
        expectedFixedHeader = FixedHeader(type: .disconnect, remainingLength: .zero)
        XCTAssertEqual(fixedHeader, expectedFixedHeader)

        bytes = [0b11110000, 0]
        buffer.writeBytes(bytes)
        fixedHeader = try! buffer.readFixedHeader()!
        expectedFixedHeader = FixedHeader(type: .auth, remainingLength: .zero)
        XCTAssertEqual(fixedHeader, expectedFixedHeader)
    }

    func testWrite() {
        var fixedHeader = FixedHeader(type: .connect, remainingLength: .zero)
        var expectedByte: UInt8 = 0b00010000
        try! buffer.write(fixedHeader)
        XCTAssertEqual(buffer.readByte(), expectedByte)
        XCTAssertEqual(buffer.readByte(), 0)

        fixedHeader = FixedHeader(type: .connAck, remainingLength: .zero)
        expectedByte = 0b00100000
        try! buffer.write(fixedHeader)
        XCTAssertEqual(buffer.readByte(), expectedByte)
        XCTAssertEqual(buffer.readByte(), 0)

        fixedHeader = FixedHeader(
            type: .publish,
            flags: .publish(dup: false, qos: .atLeastOnce, retain: true),
            remainingLength: .zero)
        expectedByte = 0b00110011 // DUP: false, QoS: 1, Retain: true
        try! buffer.write(fixedHeader)
        XCTAssertEqual(buffer.readByte(), expectedByte)
        XCTAssertEqual(buffer.readByte(), 0)

        fixedHeader = FixedHeader(type: .pubAck, remainingLength: .zero)
        expectedByte = 0b01000000
        try! buffer.write(fixedHeader)
        XCTAssertEqual(buffer.readByte(), expectedByte)
        XCTAssertEqual(buffer.readByte(), 0)

        fixedHeader = FixedHeader(type: .pubRec, remainingLength: .zero)
        expectedByte = 0b01010000
        try! buffer.write(fixedHeader)
        XCTAssertEqual(buffer.readByte(), expectedByte)
        XCTAssertEqual(buffer.readByte(), 0)

        fixedHeader = FixedHeader(type: .pubRel, remainingLength: .zero)
        expectedByte = 0b01100010
        try! buffer.write(fixedHeader)
        XCTAssertEqual(buffer.readByte(), expectedByte)
        XCTAssertEqual(buffer.readByte(), 0)

        fixedHeader = FixedHeader(type: .pubComp, remainingLength: .zero)
        expectedByte = 0b01110000
        try! buffer.write(fixedHeader)
        XCTAssertEqual(buffer.readByte(), expectedByte)
        XCTAssertEqual(buffer.readByte(), 0)

        fixedHeader = FixedHeader(type: .subscribe, remainingLength: .zero)
        expectedByte = 0b10000010
        try! buffer.write(fixedHeader)
        XCTAssertEqual(buffer.readByte(), expectedByte)
        XCTAssertEqual(buffer.readByte(), 0)

        fixedHeader = FixedHeader(type: .subAck, remainingLength: .zero)
        expectedByte = 0b10010000
        try! buffer.write(fixedHeader)
        XCTAssertEqual(buffer.readByte(), expectedByte)
        XCTAssertEqual(buffer.readByte(), 0)

        fixedHeader = FixedHeader(type: .unsubscribe, remainingLength: .zero)
        expectedByte = 0b10100010
        try! buffer.write(fixedHeader)
        XCTAssertEqual(buffer.readByte(), expectedByte)
        XCTAssertEqual(buffer.readByte(), 0)

        fixedHeader = FixedHeader(type: .unsubAck, remainingLength: .zero)
        expectedByte = 0b10110000
        try! buffer.write(fixedHeader)
        XCTAssertEqual(buffer.readByte(), expectedByte)
        XCTAssertEqual(buffer.readByte(), 0)

        fixedHeader = FixedHeader(type: .pingReq, remainingLength: .zero)
        expectedByte = 0b11000000
        try! buffer.write(fixedHeader)
        XCTAssertEqual(buffer.readByte(), expectedByte)
        XCTAssertEqual(buffer.readByte(), 0)

        fixedHeader = FixedHeader(type: .pingResp, remainingLength: .zero)
        expectedByte = 0b11010000
        try! buffer.write(fixedHeader)
        XCTAssertEqual(buffer.readByte(), expectedByte)
        XCTAssertEqual(buffer.readByte(), 0)

        fixedHeader = FixedHeader(type: .disconnect, remainingLength: .zero)
        expectedByte = 0b11100000
        try! buffer.write(fixedHeader)
        XCTAssertEqual(buffer.readByte(), expectedByte)
        XCTAssertEqual(buffer.readByte(), 0)

        fixedHeader = FixedHeader(type: .auth, remainingLength: .zero)
        expectedByte = 0b11110000
        try! buffer.write(fixedHeader)
        XCTAssertEqual(buffer.readByte(), expectedByte)
        XCTAssertEqual(buffer.readByte(), 0)
    }
}
