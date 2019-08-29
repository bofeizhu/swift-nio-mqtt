//
//  PacketComponentIOTests.swift
//  NIOMQTTTests
//
//  Created by Bofei Zhu on 8/21/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

import struct Foundation.Data
import XCTest
import NIO

@testable import NIOMQTT

// swiftlint:disable force_try

class PacketComponentIOTests: ByteBufferTestCase {

    // MARK: Fixed Header

    func testMakeFixedHeader() {
        let fixedHeader = FixedHeader.makeReservedFixHeader(of: .connect, withRemainingLength: 0)
        XCTAssertEqual(fixedHeader.type, ControlPacketType.connect)
        XCTAssertEqual(fixedHeader.flags, FixedHeaderFlags.reserved(value: 0))
    }

    // MARK: Reason Code

    func testReadReasonCode() {
        let reasonCodeValue: UInt8 = 0
        buffer.writeInteger(reasonCodeValue)
        let reasonCode: ConnectPacket.ReasonCode = try! buffer.readReasonCode()
        XCTAssertEqual(reasonCode, ConnectPacket.ReasonCode.success)
        XCTAssertEqual(buffer.readableBytes, 0)
    }

    func testReadReasonCodeError() {
        let reasonCodeValue: UInt8 = 1
        buffer.writeInteger(reasonCodeValue)
        var buffer = self.buffer!
        XCTAssertThrowsError(try buffer.readReasonCode() as ConnectPacket.ReasonCode)
    }

    func testReadReasonCodeList() {
        let reasonCodeValues: [UInt8] = [0, 128]
        buffer.writeBytes(reasonCodeValues)
        let reasonCodes: [SubAckPacket.ReasonCode] = try! buffer.readReasonCodeList(length: 2)
        XCTAssertEqual(reasonCodes[0], SubAckPacket.ReasonCode.grantedQoS0)
        XCTAssertEqual(reasonCodes[1], SubAckPacket.ReasonCode.unspecifiedError)
        XCTAssertEqual(buffer.readableBytes, 0)
    }

    func testReadReasonCodeListError() {
        let reasonCodeValues: [UInt8] = [0, 5]
        buffer.writeBytes(reasonCodeValues)
        var buffer = self.buffer!
        XCTAssertThrowsError(try buffer.readReasonCodeList(length: 2) as [SubAckPacket.ReasonCode])
    }
}
