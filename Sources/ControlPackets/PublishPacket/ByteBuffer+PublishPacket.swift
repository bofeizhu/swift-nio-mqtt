//
//  ByteBuffer+PublishPacket.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 8/14/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

import NIO

extension ByteBuffer {

    mutating func readPublishPacket(with fixedHeader: FixedHeader) throws -> PublishPacket {

        // MARK: Read variable header

        var variableHeaderLength = 0

        guard let topicName = readMQTTString() else {
            throw MQTTCodingError.malformedPacket
        }

        variableHeaderLength += topicName.mqttByteCount

        var packetIdentifier: UInt16?

        switch fixedHeader.flags {
        case let .publish(_, qos, _):
            if qos != .level0 {
                guard let identifier: UInt16 = readInteger() else {
                    throw MQTTCodingError.malformedPacket
                }
                packetIdentifier = identifier
            }
        default:
            throw MQTTCodingError.malformedPacket
        }

        variableHeaderLength += (packetIdentifier == nil) ? 0 : 2

        let properties = try readProperties()

        variableHeaderLength += properties.mqttByteCount

        let variableHeader = PublishPacket.VariableHeader(
            topicName: topicName,
            packetIdentifier: packetIdentifier,
            properties: properties)

        // MARK: Read payload

        let payloadLength = Int(fixedHeader.remainingLength.value) - variableHeaderLength
        guard
            let payload = readDataPayload(length: payloadLength, isUTF8Encoded: properties.isPayloadUTF8Encoded),
            let publishPacket = PublishPacket(
                fixedHeader: fixedHeader,
                variableHeader: variableHeader,
                payload: payload)
        else { throw MQTTCodingError.malformedPacket }

        return publishPacket
    }
}
