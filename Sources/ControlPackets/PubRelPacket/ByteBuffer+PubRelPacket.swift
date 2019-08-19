//
//  ByteBuffer+PubRelPacket.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 8/14/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

import NIO

extension ByteBuffer {

    mutating func readPubRelPacket(with fixedHeader: FixedHeader) throws -> PubRelPacket {

        guard
            let packetIdentifier: UInt16 = readInteger(),
            let reasonCodeValue = readByte(),
            let reasonCode = PubRelPacket.ReasonCode(rawValue: reasonCodeValue)
        else {
            throw MQTTCodingError.malformedPacket
        }

        let properties = try readProperties()

        let variableHeader = PubRelPacket.VariableHeader(
            packetIdentifier: packetIdentifier,
            reasonCode: reasonCode,
            properties: properties)

        return PubRelPacket(fixedHeader: fixedHeader, variableHeader: variableHeader)
    }
}
