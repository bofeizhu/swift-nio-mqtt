//
//  ByteBufferTestCase.swift
//  MQTTCodecTests
//
//  Created by Bofei Zhu on 7/18/19.
//  Copyright © 2019 Bofei Zhu. All rights reserved.
//

import struct Foundation.Data
import XCTest
import NIO

@testable import MQTTCodec

class ByteBufferTestCase: XCTestCase {

    let allocator = ByteBufferAllocator()
    var buffer: ByteBuffer! = nil

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
}
