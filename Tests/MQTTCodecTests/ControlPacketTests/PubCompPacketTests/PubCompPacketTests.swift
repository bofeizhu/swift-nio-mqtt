//
//  PubCompPacketTests.swift
//  MQTTCodecTests
//
//  Created by Bofei Zhu on 11/16/19.
//  Copyright © 2019 Bofei Zhu. All rights reserved.
//

import XCTest

@testable import MQTTCodec

final class PubCompPacketTests: XCTestCase {

    func testVariableHeaderByteCountWhenReasonCodeIsSuccess() {
        var variableHeader = PubCompPacket.VariableHeader(
            packetIdentifier: .zero,
            reasonCode: .success,
            properties: PropertyCollection())

        // The Reason Code and Property Length can be omitted if the Reason Code is 0x00 (Success) and
        // there are no Properties. In this case the PUBACK has a Remaining Length of 2.
        XCTAssertEqual(variableHeader.mqttByteCount, 2)

        var properties = PropertyCollection()
        properties.append(.payloadFormatIndicator(true))
        variableHeader = PubCompPacket.VariableHeader(
            packetIdentifier: .zero,
            reasonCode: .success,
            properties: properties)

        XCTAssertEqual(variableHeader.mqttByteCount, 6)
    }

    func testVariableHeaderByteCountWhenReasonCodeIsNotSuccess() {
        var variableHeader = PubCompPacket.VariableHeader(
            packetIdentifier: .zero,
            reasonCode: .packetIdentifierNotFound,
            properties: PropertyCollection())

        // If the Remaining Length is less than 4 there is no Property Length and the value of 0 is used.
        XCTAssertEqual(variableHeader.mqttByteCount, 3)

        var properties = PropertyCollection()
        properties.append(.payloadFormatIndicator(true))
        variableHeader = PubCompPacket.VariableHeader(
            packetIdentifier: .zero,
            reasonCode: .packetIdentifierNotFound,
            properties: properties)

        XCTAssertEqual(variableHeader.mqttByteCount, 6)
    }
}
