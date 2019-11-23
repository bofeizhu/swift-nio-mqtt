//
//  ByteBuffer+UnsubAckPacket.swift
//  MQTTCodec
//
//  Created by Bofei Zhu on 8/21/19.
//  Copyright © 2019 Bofei Zhu. All rights reserved.
//

import NIO

extension ByteBuffer {

    mutating func readUnsubAckPacket(with fixedHeader: FixedHeader) throws -> UnsubAckPacket {

        // MARK: Read variable header

        let packetIdentifier = try readPacketIdentifier()
        var variableHeaderLength = UInt16.byteCount

        let properties = try readProperties()
        variableHeaderLength += properties.mqttByteCount

        let variableHeader = UnsubAckPacket.VariableHeader(
            packetIdentifier: packetIdentifier,
            properties: properties)

        // MARK: Read payload

        let remainingLength = Int(fixedHeader.remainingLength.value)

        let payloadLength = remainingLength - variableHeaderLength
        let reasonCodes: [UnsubAckPacket.ReasonCode] = try readReasonCodeList(length: payloadLength)
        let payload = UnsubAckPacket.Payload(reasonCodes: reasonCodes)

        return UnsubAckPacket(fixedHeader: fixedHeader, variableHeader: variableHeader, payload: payload)
    }
}
