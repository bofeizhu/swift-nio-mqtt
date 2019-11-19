//
//  PropertyCollectionIOTests.swift
//  NIOMQTTTests
//
//  Created by Bofei Zhu on 11/18/19.
//  Copyright © 2019 Bofei Zhu. All rights reserved.
//

import XCTest
import NIO
import Foundation

@testable import NIOMQTT

// swiftlint:disable force_try

class PropertyCollectionIOTests: ByteBufferTestCase {

    func testPropertyCollectionIO() {
        var propertiesWritten = PropertyCollection()

        propertiesWritten.append(.payloadFormatIndicator(true))
        propertiesWritten.append(.messageExpiryInterval(10))
        propertiesWritten.append(.contentType("type"))
        propertiesWritten.append(.responseTopic("topic"))
        propertiesWritten.append(.correlationData("data".data(using: .utf8)!))
        propertiesWritten.append(.subscriptionIdentifier(VInt(value: 1)))
        propertiesWritten.append(.sessionExpiryInterval(30))
        propertiesWritten.append(.assignedClientIdentifier("id"))
//        propertiesWritten.append(.serverKeepAlive(30))


        try! buffer.write(propertiesWritten)

        let propertiesRead = try! buffer.readProperties()

        print(propertiesWritten)
        print(propertiesRead)

        XCTAssertEqual(buffer.readableBytes, 0)

        for i in 0..<propertiesWritten.count {
            XCTAssertEqual(propertiesRead[i], propertiesWritten[i])
        }
    }
}
