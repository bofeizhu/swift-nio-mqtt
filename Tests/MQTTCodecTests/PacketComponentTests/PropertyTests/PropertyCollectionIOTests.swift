//
//  PropertyCollectionIOTests.swift
//  MQTTCodecTests
//
//  Created by Bofei Zhu on 11/18/19.
//  Copyright © 2019 Bofei Zhu. All rights reserved.
//

import XCTest
import NIO
import Foundation

@testable import MQTTCodec

// swiftlint:disable force_try

final class PropertyCollectionIOTests: ByteBufferTestCase {

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
        propertiesWritten.append(.serverKeepAlive(30))
        propertiesWritten.append(.authenticationMethod("method"))
        propertiesWritten.append(.authenticationData("auth".data(using: .utf8)!))
        propertiesWritten.append(.requestProblemInformation(false))
        propertiesWritten.append(.willDelayInterval(1000))
        propertiesWritten.append(.requestResponseInformation(true))
        propertiesWritten.append(.responseInformation("information"))
        propertiesWritten.append(.serverReference("reference"))
        propertiesWritten.append(.reasonString("reason"))
        propertiesWritten.append(.receiveMaximum(99))
        propertiesWritten.append(.topicAliasMaximum(999))
        propertiesWritten.append(.topicAlias(23))
        propertiesWritten.append(.maximumQoS(.exactlyOnce))
        propertiesWritten.append(.retainAvailable(false))
        propertiesWritten.append(.userProperty(StringPair(name: "name", value: "value")))
        propertiesWritten.append(.maximumPacketSize(9999))
        propertiesWritten.append(.wildcardSubscriptionAvailable(false))
        propertiesWritten.append(.subscriptionIdentifierAvailable(true))
        propertiesWritten.append(.sharedSubscriptionAvailable(true))


        try! buffer.write(propertiesWritten)

        let propertiesRead = try! buffer.readProperties()

        XCTAssertEqual(buffer.readableBytes, 0)

        for i in 0..<propertiesWritten.count {
            XCTAssertEqual(propertiesRead[i], propertiesWritten[i])
        }
    }
}
