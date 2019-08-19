//
//  ByteBuffer+PubCompPacket.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 8/14/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

import NIO

extension ByteBuffer {

    mutating func readPubCompPacket(with fixedHeader: FixedHeader) throws -> PubCompPacket {

        guard
            let packetIdentifier: UInt16 = readInteger(),
            let reasonCodeValue = readByte(),
            let reasonCode = PubCompPacket.ReasonCode(rawValue: reasonCodeValue)
        else {
            throw MQTTCodingError.malformedPacket
        }

        let properties = try readProperties()

        let variableHeader = PubCompPacket.VariableHeader(
            packetIdentifier: packetIdentifier,
            reasonCode: reasonCode,
            properties: properties)

        return PubCompPacket(fixedHeader: fixedHeader, variableHeader: variableHeader)
    }
}
