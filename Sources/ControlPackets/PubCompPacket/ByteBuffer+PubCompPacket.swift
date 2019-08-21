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

        let packetIdentifier = try readPacketIdentifier()
        let reasonCode: PubCompPacket.ReasonCode = try readReasonCode()
        let properties = try readProperties()

        let variableHeader = PubCompPacket.VariableHeader(
            packetIdentifier: packetIdentifier,
            reasonCode: reasonCode,
            properties: properties)

        return PubCompPacket(fixedHeader: fixedHeader, variableHeader: variableHeader)
    }
}
