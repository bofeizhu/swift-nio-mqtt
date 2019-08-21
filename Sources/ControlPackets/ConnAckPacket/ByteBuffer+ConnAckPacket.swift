//
//  ByteBuffer+ConnAckPacket.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 8/14/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

import NIO

extension ByteBuffer {

    mutating func readConnAckPacket(with fixedHeader: FixedHeader) throws -> ConnAckPacket {

        guard let sessionPresentFlag = try readBool() else {
            throw MQTTCodingError.malformedPacket
        }

        let reasonCode: ConnectPacket.ReasonCode = try readReasonCode()
        let properties = try readProperties()

        let variableHeader = ConnAckPacket.VariableHeader(
            sessionPresentFlag: sessionPresentFlag,
            connectReasonCode: reasonCode,
            properties: properties)

        return ConnAckPacket(fixedHeader: fixedHeader, variableHeader: variableHeader)
    }
}
