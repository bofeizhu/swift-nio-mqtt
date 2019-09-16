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

// swiftlint:disable force_try

class FixedHeaderIOTests: ByteBufferTestCase {

    func testFixedHeaderMinByteCount() {
        let fixedHeader = FixedHeader.makeReservedFixHeader(of: .connect, withRemainingLength: .zero)
        XCTAssertEqual(2, try! buffer.write(fixedHeader))
        XCTAssertEqual(2, buffer.readableBytes)
    }

    func testFixedHeaderMaxByteCount() {
        let fixedHeader = FixedHeader.makeReservedFixHeader(of: .connect, withRemainingLength: VInt.max)
        XCTAssertEqual(5, try! buffer.write(fixedHeader))
        XCTAssertEqual(5, buffer.readableBytes)
    }

    func testWrite() {
        let fixedHeader = FixedHeader.makeReservedFixHeader(of: .unsubscribe, withRemainingLength: .zero)
        let expectedByte: UInt8 = 0b10100010

        _ = try! buffer.write(fixedHeader)

        XCTAssertEqual(buffer.readByte(), expectedByte)
    }

    func testPublishWrite() {
        let fixedHeader = FixedHeader(
            type: .publish,
            flags: .publish(dup: false, qos: .level1, retain: true),
            remainingLength: .zero
        )

        let expectedByte: UInt8 = 0b110011 // DUP: false, QoS: 1, Retain: true
        _ = try! buffer.write(fixedHeader)

        XCTAssertEqual(buffer.readByte(), expectedByte)
    }
}
