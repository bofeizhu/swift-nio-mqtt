//
//  MQTTErrors.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 6/17/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

// MARK: - Coding Errors

enum MQTTCodingError: Error {

    /// Value too large. The maximum number of bytes in the VInt field is four.
    case malformedVariableByteInteger

    case malformedPacket

    case utf8StringTooLong

    case binaryDataTooLong
}
