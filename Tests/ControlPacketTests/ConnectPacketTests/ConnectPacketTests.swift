//
//  ConnectPacketTests.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 8/24/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

import XCTest

@testable import NIOMQTT

class ConnectPacketTests: XCTestCase {

    func testVariableHeaderByteCount() {

        let connectFlags = ConnectPacket.ConnectFlags(rawValue: 0)!
        let properties = PropertyCollection()

        let variableHeader = ConnectPacket.VariableHeader(
            connectFlags: connectFlags,
            keepAlive: 120,
            properties: properties)

        XCTAssertEqual(variableHeader.mqttByteCount, 11)
    }
}
