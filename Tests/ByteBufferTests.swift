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

// swiftlint:disable force_try

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

    // MARK: MQTT UTF-8 Encoded String

    func testMQTTStringRead() {
        let string = "test"
        let count = UInt16(string.count)
        buffer.writeInteger(count)
        buffer.writeString(string)
        let mqttString = buffer.readMQTTString()
        XCTAssertEqual(string, mqttString)
        XCTAssertEqual(buffer.readableBytes, 0)
    }

    func testMQTTStringWrite() {
        let string = "test"
        let written = try! buffer.writeMQTTString(string)
        XCTAssertEqual(written, string.count + 2)
        let count: UInt16 = buffer.readInteger()!
        XCTAssertEqual(Int(count), string.count)
        let readString = buffer.readString(length: Int(count))
        XCTAssertEqual(string, readString)
    }

    // MARK: - VInt

    func testVIntRead() {

        // Test 0
        buffer.writeByte(0)
        var integer = buffer.readVariableByteInteger()
        XCTAssertEqual(integer, VInt(value: 0))
        XCTAssertEqual(buffer.readableBytes, 0)

        // Test 127
        buffer.writeByte(127)
        integer = buffer.readVariableByteInteger()
        XCTAssertEqual(integer, VInt(value: 127))
        XCTAssertEqual(buffer.readableBytes, 0)

        // Test 128
        buffer.writeBytes([UInt8(0x80), UInt8(0x01)])
        integer = buffer.readVariableByteInteger()
        XCTAssertEqual(integer, VInt(value: 128))
        XCTAssertEqual(buffer.readableBytes, 0)

        // Test 16,383
        buffer.writeBytes([UInt8(0xFF), UInt8(0x7F)])
        integer = buffer.readVariableByteInteger()
        XCTAssertEqual(integer, VInt(value: 16383))
        XCTAssertEqual(buffer.readableBytes, 0)

        // Test 2,097,152
        buffer.writeBytes([UInt8(0x80), UInt8(0x80), UInt8(0x80), UInt8(0x01)])
        integer = buffer.readVariableByteInteger()
        XCTAssertEqual(integer, VInt(value: 2097152))
        XCTAssertEqual(buffer.readableBytes, 0)

        // Test 268,435,455
        buffer.writeBytes([UInt8(0xFF), UInt8(0xFF), UInt8(0xFF), UInt8(0x7F)])
        integer = buffer.readVariableByteInteger()
        XCTAssertEqual(integer, VInt(value: 268435455))
        XCTAssertEqual(buffer.readableBytes, 0)
    }

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

    // MARK: MQTT Binary Data

    func testBinaryDataRead() {
        let bytes: [UInt8] = [0x00, 0x01, 0x02, 0x03]
        let data = Data(bytes)
        buffer.writeInteger(UInt16(4))
        buffer.writeBytes(bytes)
        let dataRead = buffer.readMQTTBinaryData()
        XCTAssertEqual(data, dataRead)
        XCTAssertEqual(buffer.readableBytes, 0)
    }

    func testBinaryDataWrite() {
        let bytes: [UInt8] = [0x00, 0x01, 0x02, 0x03]
        let data = Data(bytes)
        let written = try! buffer.writeMQTTBinaryData(data)
        XCTAssertEqual(written, 6)
        let count: UInt16 = buffer.readInteger()!
        XCTAssertEqual(Int(count), 4)
        let bytesWritten = buffer.readBytes(length: Int(count))
        XCTAssertEqual(bytes, bytesWritten)
    }

    // MARK: String Pair

    func testStringPairRead() {
        let name = "name"
        let value = "value"
        try! buffer.writeMQTTString(name)
        try! buffer.writeMQTTString(value)
        let pair = buffer.readStringPair()
        XCTAssertEqual(name, pair?.name)
        XCTAssertEqual(value, pair?.value)
        XCTAssertEqual(buffer.readableBytes, 0)
    }

    func testStringPairWrite() {
        let name = "name"
        let value = "value"
        let pair = StringPair(name: name, value: value)
        let written = try! buffer.write(pair)
        XCTAssertEqual(written, name.count + value.count + 4)
        let nameWritten = buffer.readMQTTString()
        let valueWritten = buffer.readMQTTString()
        XCTAssertEqual(name, nameWritten)
        XCTAssertEqual(value, valueWritten)
    }
}
