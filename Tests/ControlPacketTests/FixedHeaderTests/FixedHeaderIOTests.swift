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
            flags: .publish(dup: false, qos: .level1, retain: true),
            remainingLength: .zero)
        expectedByte = 0b110011 // DUP: false, QoS: 1, Retain: true
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
