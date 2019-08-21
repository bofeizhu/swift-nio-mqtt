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

        let packetIdentifier = try readPacketIdentifier()
        let reasonCode: PubAckPacket.ReasonCode = try readReasonCode()
        let properties = try readProperties()

        let variableHeader = PubAckPacket.VariableHeader(
            packetIdentifier: packetIdentifier,
            reasonCode: reasonCode,
            properties: properties)

        return PubAckPacket(fixedHeader: fixedHeader, variableHeader: variableHeader)
    }
}
