//
//  ByteBuffer+Property.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 8/11/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

import NIO

extension ByteBuffer {

    mutating func readProperties() throws -> [Property] {

        // Get property length in bytes

        guard let length = try readVariableByteInteger() else {
            throw MQTTCodingError.malformedPacket
        }

        var remainingLength = Int(length.value)
        var properties: [Property] = []

        while remainingLength > 0 {

            // Although the Property Identifier is defined as a Variable Byte Integer,
            // in this version of the specification all of the Property Identifiers are one byte long.
            guard
                let identifierByte = readByte(),
                let identifier = PropertyIdentifier(rawValue: identifierByte)
            else {
                throw MQTTCodingError.malformedPacket
            }
            remainingLength -= 1

            let (property, length) = try readProperty(of: identifier)
            properties.append(property)
            remainingLength -= length
        }
        return properties
    }

    private mutating func readProperty(of identifier: PropertyIdentifier) throws -> (Property, Int) {
        switch identifier {
        case .payloadFormatIndicator:
            guard let byte = readByte(), byte == 0 || byte == 1 else {
                throw MQTTCodingError.malformedPacket
            }

            let isUTF8Encoded = byte == 1
            return (.payloadFormatIndicator(isUTF8Encoded), 1)

        case .messageExpiryInterval:
            guard let interval: UInt32 = readInteger() else {
                throw MQTTCodingError.malformedPacket
            }
            // Four byte integer
            return (.messageExpiryInterval(interval), 4)

        case .contentType:
            guard let contentType = readMQTTString() else {
                throw MQTTCodingError.malformedPacket
            }
            return (.contentType(contentType), contentType.mqttByteCount)

        case .responseTopic:
            guard let topic = readMQTTString() else {
                throw MQTTCodingError.malformedPacket
            }
            return (.responseTopic(topic), topic.mqttByteCount)

        case .correlationData:
            guard let data = readMQTTBinaryData() else {
                throw MQTTCodingError.malformedPacket
            }
            return (.correlationData(data), data.mqttByteCount)

        case .subscriptionIdentifier:
            guard let identifier = try readVariableByteInteger() else {
                throw MQTTCodingError.malformedPacket
            }
            return (.subscriptionIdentifier(identifier), identifier.bytes.count)

        case .assignedClientIdentifier:
            guard let identifier = readMQTTString() else {
                throw MQTTCodingError.malformedPacket
            }
            return (.assignedClientIdentifier(identifier), identifier.mqttByteCount)

        case .serverKeepAlive:
            guard let keepAlive: UInt16 = readInteger() else {
                throw MQTTCodingError.malformedPacket
            }
            // Two byte integer
            return (.serverKeepAlive(keepAlive), 2)

        default:
            throw MQTTCodingError.malformedPacket
        }
    }
}
