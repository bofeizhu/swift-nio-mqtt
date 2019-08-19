//
//  ByteBuffer+PubRecPacket.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 8/14/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

import NIO

extension ByteBuffer {

    mutating func readPubRecPacket(with fixedHeader: FixedHeader) throws -> PubRecPacket {

        guard
            let packetIdentifier: UInt16 = readInteger(),
            let reasonCodeValue = readByte(),
            let reasonCode = PubRecPacket.ReasonCode(rawValue: reasonCodeValue)
        else {
            throw MQTTCodingError.malformedPacket
        }

        let properties = try readProperties()

        let variableHeader = PubRecPacket.VariableHeader(
            packetIdentifier: packetIdentifier,
            reasonCode: reasonCode,
            properties: properties)

        return PubRecPacket(fixedHeader: fixedHeader, variableHeader: variableHeader)
    }
}
