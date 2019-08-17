//
//  PropertyTests.swift
//  NIOMQTTTests
//
//  Created by Bofei Zhu on 7/18/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

import struct Foundation.Data
import XCTest
import NIO

@testable import NIOMQTT

class PropertyTests: XCTestCase {

    func testByteCount() {

        let bytes: [UInt8] = [1, 1, 1]
        let data = Data(bytes)

        var property: Property = .payloadFormatIndicator(true)
        XCTAssertEqual(property.byteCount, 2)

        property = .messageExpiryInterval(5)
        XCTAssertEqual(property.byteCount, 5)

        property = .contentType("abcde")
        XCTAssertEqual(property.byteCount, 8)

        property = .responseTopic("abcde")
        XCTAssertEqual(property.byteCount, 8)

        property = .correlationData(data)
        XCTAssertEqual(property.byteCount, 6)

        property = .subscriptionIdentifier(VInt(value: 0))
        XCTAssertEqual(property.byteCount, 2)

        property = .sessionExpiryInterval(5)
        XCTAssertEqual(property.byteCount, 5)

    }
}
