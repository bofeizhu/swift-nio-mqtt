//
//  SwiftNIOMQTTTests.swift
//  SwiftNIOMQTTTests
//
//  Created by Bofei Zhu on 6/11/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

import XCTest
@testable import SwiftNIOMQTT

class SwiftNIOMQTTTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let integer = VInt(value: 12)
        XCTAssertEqual(integer.hasFollowing, false)
    }
}
