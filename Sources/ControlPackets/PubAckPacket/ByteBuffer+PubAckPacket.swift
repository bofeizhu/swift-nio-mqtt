//
//  ByteBuffer+PubAckPacket.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 8/14/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

import NIO

extension ByteBuffer {

    mutating func readPubAckPacket(with fixedHeader: FixedHeader) throws -> PubAckPacket {

        guard
            let packetIdentifier: UInt16 = readInteger(),
            let reasonCodeValue = readByte(),
            let reasonCode = PubAckPacket.ReasonCode(rawValue: reasonCodeValue)
        else {
            throw MQTTCodingError.malformedPacket
        }

        let properties = try readProperties()

        let variableHeader = PubAckPacket.VariableHeader(
            packetIdentifier: packetIdentifier,
            reasonCode: reasonCode,
            properties: properties)

        return PubAckPacket(fixedHeader: fixedHeader, variableHeader: variableHeader)
    }
}
