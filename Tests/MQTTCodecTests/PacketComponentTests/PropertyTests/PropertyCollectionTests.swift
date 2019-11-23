//
//  PropertyCollectionTests.swift
//  MQTTCodecTests
//
//  Created by Bofei Zhu on 8/23/19.
//  Copyright © 2019 Bofei Zhu. All rights reserved.
//

import XCTest

@testable import MQTTCodec

final class PropertyCollectionTests: XCTestCase {

    private var properties = PropertyCollection()

    override func setUp() {
        super.setUp()

        properties = PropertyCollection()
    }

    func testAppend() {
        let property: Property = .maximumPacketSize(16)
        properties.append(property)

        XCTAssertEqual(properties.startIndex, 0)
        XCTAssertEqual(properties.endIndex, 1)
        XCTAssertEqual(properties.index(after: 0), 1)
        XCTAssertEqual(properties[0], property)
    }

    func testAppendPayloadFormatIndicator() {
        let property: Property = .payloadFormatIndicator(true)
        properties.append(property)

        XCTAssertTrue(properties.isPayloadUTF8Encoded)
    }

    func testPropertyLength() {
        XCTAssertEqual(properties.propertyLength, VInt(value: 0))
        XCTAssertEqual(properties.mqttByteCount, 1)

        let property: Property = .maximumPacketSize(16)
        properties.append(property)

        XCTAssertEqual(properties.propertyLength, VInt(value: 5))
        XCTAssertEqual(properties.mqttByteCount, 6)
    }
}
