//
//  FixedHeaderTests.swift
//  NIOMQTT
//
//  Created by Elian Imlay-Maire on 9/12/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

import XCTest
import NIO

@testable import NIOMQTT

// swiftlint:disable force_try

class FixedHeaderIOTests: ByteBufferTestCase {

    func testFixedHeaderMinByteCount() {
        let type = ControlPacketType.connect

        let fixedHeader = FixedHeader(
            type: type,
            flags: FixedHeaderFlags(type: type)!,
            remainingLength: VInt(value: .zero)
        )

        XCTAssertEqual(2, try! buffer.write(fixedHeader))
        XCTAssertEqual(2, buffer.readableBytes)
    }

    func testFixedHeaderMaxByteCount() {
        let type = ControlPacketType.disconnect

        let fixedHeader = FixedHeader(
            type: type,
            flags: FixedHeaderFlags(type: type)!,
            remainingLength: VInt(value: UInt(exactly: VInt.max)!)
        )

        XCTAssertEqual(5, try! buffer.write(fixedHeader))
        XCTAssertEqual(5, buffer.readableBytes)
    }

    func testPublishByteCount() {
        let fixedHeader = FixedHeader(
            type: .publish,
            flags: .publish(
                dup: false,
                qos: .level0,
                retain: false
            ),
            remainingLength: VInt(value: .zero)
        )

        XCTAssertEqual(2, try! buffer.write(fixedHeader))
        XCTAssertEqual(2, buffer.readableBytes)
    }

    func testReadFixedHeader() {
        let type = ControlPacketType.auth

        let inputHeader = FixedHeader(
            type: type,
            flags: FixedHeaderFlags(type: type)!,
            remainingLength: VInt(value: .zero)
        )

        _ = try! buffer.write(inputHeader)
        let outputHeader = try! buffer.getFixedHeader(at: 0)!

        XCTAssertEqual(inputHeader.flags, outputHeader.flags)
        XCTAssertEqual(inputHeader.remainingLength, outputHeader.remainingLength)
        XCTAssertEqual(inputHeader.type, outputHeader.type)
    }
}
