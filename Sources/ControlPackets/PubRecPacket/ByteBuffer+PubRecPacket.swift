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

        let packetIdentifier = try readPacketIdentifier()
        let reasonCode: PubRecPacket.ReasonCode = try readReasonCode()
        let properties = try readProperties()

        let variableHeader = PubRecPacket.VariableHeader(
            packetIdentifier: packetIdentifier,
            reasonCode: reasonCode,
            properties: properties)

        return PubRecPacket(fixedHeader: fixedHeader, variableHeader: variableHeader)
    }
}
