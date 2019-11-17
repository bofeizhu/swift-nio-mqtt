//
//  PubAckPacketBuilderTests.swift
//  NIOMQTTTests
//
//  Created by Bofei Zhu on 11/16/19.
//  Copyright © 2019 Bofei Zhu. All rights reserved.
//

import XCTest
import NIO
import Foundation

@testable import NIOMQTT

class PubAckPacketBuilderTests: XCTestCase {

    var builder: PubAckPacketBuilder!

    override func setUp() {
        super.setUp()

        builder = PubAckPacketBuilder(packetIdentifier: .zero)
    }

    override func tearDown() {
        builder = nil

        super.tearDown()
    }

    func testReasonCode() {
        let packet = builder.reasonCode(.implementationSpecificError).build()
        XCTAssertEqual(packet.variableHeader.reasonCode, .implementationSpecificError)
    }
}
