//
//  PropertyTests.swift
//  NIOMQTTTests
//
//  Created by Bofei Zhu on 7/18/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

import XCTest

@testable import NIOMQTT

//swiftlint:disable function_body_length

class PropertyTests: XCTestCase {

    func testByteCount() {

        // MARK: Boolean Type Properties (Byte Type)

        let boolPropertyByteCount = 2

        var property: Property = .payloadFormatIndicator(true)
        XCTAssertEqual(property.mqttByteCount, boolPropertyByteCount)

        property = .requestProblemInformation(true)
        XCTAssertEqual(property.mqttByteCount, boolPropertyByteCount)

        property = .requestResponseInformation(true)
        XCTAssertEqual(property.mqttByteCount, boolPropertyByteCount)

        property = .retainAvailable(true)
        XCTAssertEqual(property.mqttByteCount, boolPropertyByteCount)

        property = .wildcardSubscriptionAvailable(true)
        XCTAssertEqual(property.mqttByteCount, boolPropertyByteCount)

        property = .subscriptionIdentifierAvailable(true)
        XCTAssertEqual(property.mqttByteCount, boolPropertyByteCount)

        property = .sharedSubscriptionAvailable(true)
        XCTAssertEqual(property.mqttByteCount, boolPropertyByteCount)

        // MARK: Four Byte Integer Type Properties

        let fourByteInteger: UInt32 = 42
        let fourByteIntegerPropertyByteCount = 5

        property = .messageExpiryInterval(fourByteInteger)
        XCTAssertEqual(property.mqttByteCount, fourByteIntegerPropertyByteCount)

        property = .sessionExpiryInterval(fourByteInteger)
        XCTAssertEqual(property.mqttByteCount, fourByteIntegerPropertyByteCount)

        property = .willDelayInterval(fourByteInteger)
        XCTAssertEqual(property.mqttByteCount, fourByteIntegerPropertyByteCount)

        property = .maximumPacketSize(fourByteInteger)
        XCTAssertEqual(property.mqttByteCount, fourByteIntegerPropertyByteCount)

        // MARK: UTF-8 Encoded String Type Properties

        let string = "abcde"
        let utf8EncodedStringPropertyByteCount = 8 // 1 + 2 + 5

        property = .contentType(string)
        XCTAssertEqual(property.mqttByteCount, utf8EncodedStringPropertyByteCount)

        property = .responseTopic(string)
        XCTAssertEqual(property.mqttByteCount, utf8EncodedStringPropertyByteCount)

        property = .assignedClientIdentifier(string)
        XCTAssertEqual(property.mqttByteCount, utf8EncodedStringPropertyByteCount)

        property = .authenticationMethod(string)
        XCTAssertEqual(property.mqttByteCount, utf8EncodedStringPropertyByteCount)

        property = .responseInformation(string)
        XCTAssertEqual(property.mqttByteCount, utf8EncodedStringPropertyByteCount)

        property = .serverReference(string)
        XCTAssertEqual(property.mqttByteCount, utf8EncodedStringPropertyByteCount)

        property = .reasonString(string)
        XCTAssertEqual(property.mqttByteCount, utf8EncodedStringPropertyByteCount)

        // MARK: Binary Data Type Properties

        let bytes: [UInt8] = [1, 1, 1]
        let data = Data(bytes)
        let binaryDataTypePropertByteCount = 6 // 1 + 2 + 3

        property = .correlationData(data)
        XCTAssertEqual(property.mqttByteCount, binaryDataTypePropertByteCount)

        property = .authenticationData(data)
        XCTAssertEqual(property.mqttByteCount, binaryDataTypePropertByteCount)

        // MARK: Variable Byte Integer Type Properties

        let variableByteInteger = VInt(value: 42424242)
        let variableByteIntegerPropertyByteCount = 1 + variableByteInteger.mqttByteCount

        property = .subscriptionIdentifier(variableByteInteger)
        XCTAssertEqual(property.mqttByteCount, variableByteIntegerPropertyByteCount)

        // MARK: Two Byte Integer Type Properties

        let twoByteInteger: UInt16 = 42
        let twoByteIntegerPropertyByteCount = 3

        property = .serverKeepAlive(twoByteInteger)
        XCTAssertEqual(property.mqttByteCount, twoByteIntegerPropertyByteCount)

        property = .receiveMaximum(twoByteInteger)
        XCTAssertEqual(property.mqttByteCount, twoByteIntegerPropertyByteCount)

        property = .topicAliasMaximum(twoByteInteger)
        XCTAssertEqual(property.mqttByteCount, twoByteIntegerPropertyByteCount)

        property = .topicAlias(twoByteInteger)
        XCTAssertEqual(property.mqttByteCount, twoByteIntegerPropertyByteCount)

        // MARK: QoS Type Property (Byte Type)

        let qos = QoS.level2
        let qosPropertyByteCount = 2

        property = .maximumQoS(qos)
        XCTAssertEqual(property.mqttByteCount, qosPropertyByteCount)

        // MARK: String Pair Type Property
        let pair = StringPair(name: "foo", value: "bar")
        let stringPairTypePropertyByteCount = 11

        property = .userProperty(pair)
        XCTAssertEqual(property.mqttByteCount, stringPairTypePropertyByteCount)
    }
}
