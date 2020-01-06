//
//  ConfigurationTests.swift
//  NIOMQTTClientTests
//
//  Created by Bofei Zhu on 7/18/19.
//  Copyright © 2019 Bofei Zhu. All rights reserved.
//

import struct Foundation.Data
import MQTTCodec
import XCTest
import NIO

@testable import NIOMQTTClient

final class ConfigurationTests: XCTestCase {
    func testInit() {
        let host = "mqtt.example.com"
        let port = 80
        let clientId = "clientId"
        let username = "username"
        let password = "pwd".data(using: .utf8)
        let configuration = MQTTClient.Configuration(
            host: host,
            port: port,
            clientId: clientId,
            username: username,
            password: password
        )
        XCTAssertEqual(configuration.host, host)
        XCTAssertEqual(configuration.port, port)
        XCTAssertEqual(configuration.clientId, clientId)
        XCTAssertEqual(configuration.qos, .atMostOnce)
        XCTAssertEqual(configuration.username, username)
        XCTAssertEqual(configuration.password, password)
    }
}
