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
        if let data = buffer.readByte() {
            XCTAssertEqual(data, 0)
        }

        // Test 127
        integer = VInt(value: 127)
        written = buffer.writeVariableByteInteger(integer)
        XCTAssertEqual(written, 1)
        if let data = buffer.readByte() {
            XCTAssertEqual(data, 127)
        }


        // Test 128

    }
}
