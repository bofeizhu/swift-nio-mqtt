//
//  MQTTErrors.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 6/17/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

// MARK: - Coding Errors

enum MQTTCodingError: Error {
    case malformedVariableByteInteger
    case malformedPacket
    case utf8StringTooLong
    case binaryDataTooLong
}
