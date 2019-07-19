//
//  ByteBufferTests.swift
//  NIOMQTTTests
//
//  Created by Bofei Zhu on 7/18/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

import struct Foundation.Data
import XCTest
import NIO

@testable import NIOMQTT

class ByteBufferTest: XCTestCase {
    private let allocator = ByteBufferAllocator()
    private var buffer: ByteBuffer! = nil

    override func setUp() {
        super.setUp()

        buffer = allocator.buffer(capacity: 1024)
        buffer.writeBytes(Array(repeating: UInt8(0xff), count: 1024))
        buffer = buffer.getSlice(at: 256, length: 512)
        buffer.clear()
    }

    override func tearDown() {
        buffer = nil

        super.tearDown()
    }

    // MARK: - VInt

    func testVIntWrite() {

        // Test 0
        var integer = VInt(value: 0)
        var written = buffer.writeVariableByteInteger(integer)
        XCTAssertEqual(written, 1)
        var data = buffer.readBytes(length: 1)!
        XCTAssertEqual(data, [0])

        // Test 127
        integer = VInt(value: 127)
        written = buffer.writeVariableByteInteger(integer)
        XCTAssertEqual(written, 1)
        data = buffer.readBytes(length: 1)!
        XCTAssertEqual(data, [127])

        // Test 128
        integer = VInt(value: 128)
        written = buffer.writeVariableByteInteger(integer)
        XCTAssertEqual(written, 2)
        data = buffer.readBytes(length: 2)!
        XCTAssertEqual(data, [UInt8(0x80), UInt8(0x01)])

        // Test 16,383
        integer = VInt(value: 16383)
        written = buffer.writeVariableByteInteger(integer)
        XCTAssertEqual(written, 2)
        data = buffer.readBytes(length: 2)!
        XCTAssertEqual(data, [UInt8(0xFF), UInt8(0x7F)])

        // Test 2,097,152
        integer = VInt(value: 2097152)
        written = buffer.writeVariableByteInteger(integer)
        XCTAssertEqual(written, 4)
        data = buffer.readBytes(length: 4)!
        XCTAssertEqual(data, [UInt8(0x80), UInt8(0x80), UInt8(0x80), UInt8(0x01)])

        // Test 268,435,455
        integer = VInt(value: 268435455)
        written = buffer.writeVariableByteInteger(integer)
        XCTAssertEqual(written, 4)
        data = buffer.readBytes(length: 4)!
        XCTAssertEqual(data, [UInt8(0xFF), UInt8(0xFF), UInt8(0xFF), UInt8(0x7F)])
    }
}
