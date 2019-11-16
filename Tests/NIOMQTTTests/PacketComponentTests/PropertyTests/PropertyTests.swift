//
//  PropertyTests.swift
//  NIOMQTTTests
//
//  Created by Bofei Zhu on 7/18/19.
//  Copyright © 2019 Bofei Zhu. All rights reserved.
//

import XCTest

@testable import NIOMQTT

class PropertyTests: XCTestCase {

    func testBooleanTypePropertyByteCount() {
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
    }

    func testFourByteIntegerTypePropertyByteCount() {
        let fourByteInteger: UInt32 = 42
        let fourByteIntegerPropertyByteCount = 5

        var property: Property = .messageExpiryInterval(fourByteInteger)
        XCTAssertEqual(property.mqttByteCount, fourByteIntegerPropertyByteCount)

        property = .sessionExpiryInterval(fourByteInteger)
        XCTAssertEqual(property.mqttByteCount, fourByteIntegerPropertyByteCount)

        property = .willDelayInterval(fourByteInteger)
        XCTAssertEqual(property.mqttByteCount, fourByteIntegerPropertyByteCount)

        property = .maximumPacketSize(fourByteInteger)
        XCTAssertEqual(property.mqttByteCount, fourByteIntegerPropertyByteCount)
    }

    func testUTF8EncodedStringTypePropertyByteCount() {
        let string = "abcde"
        let utf8EncodedStringPropertyByteCount = 8 // 1 + 2 + 5

        var property: Property = .contentType(string)
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
    }

    func testBinaryDataTypePropertyByteCount() {
        let bytes: [UInt8] = [1, 1, 1]
        let data = Data(bytes)
        let binaryDataTypePropertByteCount = 6 // 1 + 2 + 3

        var property: Property = .correlationData(data)
        XCTAssertEqual(property.mqttByteCount, binaryDataTypePropertByteCount)

        property = .authenticationData(data)
        XCTAssertEqual(property.mqttByteCount, binaryDataTypePropertByteCount)
    }

    func testVariableByteIntegerTypePropertyByteCount() {
        let variableByteInteger = VInt(value: 42424242)
        let variableByteIntegerPropertyByteCount = 1 + variableByteInteger.mqttByteCount

        let property: Property = .subscriptionIdentifier(variableByteInteger)
        XCTAssertEqual(property.mqttByteCount, variableByteIntegerPropertyByteCount)
    }

    func testTwoByteIntegerTypePropertyByteCount() {
        let twoByteInteger: UInt16 = 42
        let twoByteIntegerPropertyByteCount = 3

        var property: Property = .serverKeepAlive(twoByteInteger)
        XCTAssertEqual(property.mqttByteCount, twoByteIntegerPropertyByteCount)

        property = .receiveMaximum(twoByteInteger)
        XCTAssertEqual(property.mqttByteCount, twoByteIntegerPropertyByteCount)

        property = .topicAliasMaximum(twoByteInteger)
        XCTAssertEqual(property.mqttByteCount, twoByteIntegerPropertyByteCount)

        property = .topicAlias(twoByteInteger)
        XCTAssertEqual(property.mqttByteCount, twoByteIntegerPropertyByteCount)
    }

    func testQoSTypePropertyByteCount() {
        let qos = QoS.exactlyOnce
        let qosPropertyByteCount = 2

        let property: Property = .maximumQoS(qos)
        XCTAssertEqual(property.mqttByteCount, qosPropertyByteCount)
    }

    func testStringPairTypePropertyByteCount() {
        let pair = StringPair(name: "foo", value: "bar")
        let stringPairTypePropertyByteCount = 11

        let property: Property = .userProperty(pair)
        XCTAssertEqual(property.mqttByteCount, stringPairTypePropertyByteCount)
    }
}
