//
//  ByteBuffer+SubAckPacket.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 8/14/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

import NIO

extension ByteBuffer {

    mutating func readSubAckPacket(with fixedHeader: FixedHeader) throws -> SubAckPacket {

        // MARK: Read variable Header

        let packetIdentifier = try readPacketIdentifier()
        var variableHeaderLength = UInt16.byteCount

        let properties = try readProperties()
        variableHeaderLength += properties.mqttByteCount

        let variableHeader = SubAckPacket.VariableHeader(
            packetIdentifier: packetIdentifier,
            properties: properties)

        // MARK: Read payload

        let remainingLength = Int(fixedHeader.remainingLength.value)

        let payloadLength = remainingLength - variableHeaderLength
        let reasonCodes: [SubAckPacket.ReasonCode] = try readReasonCodeList(length: payloadLength)
        let payload = SubAckPacket.Payload(reasonCodes: reasonCodes)

        return SubAckPacket(fixedHeader: fixedHeader, variableHeader: variableHeader, payload: payload)
    }
}
