//
//  MQTTCodingError.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 6/17/19.
//  Copyright © 2019 Bofei Zhu. All rights reserved.
//

import protocol Foundation.LocalizedError

enum MQTTCodingError: Error {
    /// Value too large. The maximum number of bytes in the VInt field is four.
    case malformedVariableByteInteger

    case utf8StringTooLong

    case binaryDataTooLong

    case payloadFormatInvaild

    case malformedPacket
}

extension MQTTCodingError: LocalizedError {}
