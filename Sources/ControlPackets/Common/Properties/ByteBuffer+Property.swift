//
//  ByteBuffer+Property.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 8/11/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

import NIO

// swiftlint:disable cyclomatic_complexity function_body_length

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

            var property: Property?
            switch identifier {
            case .payloadFormatIndicator:
                guard
                    let byte = readByte(),
                    byte == 0 || byte == 1
                else {
                    break
                }

                let isUTF8 = byte == 1
                property = .payloadFormatIndicator(isUTF8)
                remainingLength -= 1

            case .messageExpiryInterval:
                guard let interval: UInt32 = readInteger() else {
                    break
                }
                property = .messageExpiryInterval(interval)

                // Four byte integer
                remainingLength -= 4

            case .contentType:
                guard let contentType = readMQTTString() else {
                    break
                }
                property = .contentType(contentType)
                remainingLength -= contentType.mqttByteCount

            case .responseTopic:
                guard let topic = readMQTTString() else {
                    break
                }
                property = .responseTopic(topic)
                remainingLength -= topic.mqttByteCount

            case .correlationData:
                guard let data = readMQTTBinaryData() else {
                    break
                }
                property = .correlationData(data)
                remainingLength -= data.mqttByteCount

            case .subscriptionIdentifier:
                guard let identifier = try readVariableByteInteger() else {
                    break
                }
                property = .subscriptionIdentifier(identifier)
                remainingLength -= identifier.bytes.count

            case .assignedClientIdentifier:
                guard let identifier = readMQTTString() else {
                    break
                }
                property = .assignedClientIdentifier(identifier)
                remainingLength -= identifier.mqttByteCount

            case .serverKeepAlive:
                guard let keepAlive: UInt16 = readInteger() else {
                    break
                }
                property = .serverKeepAlive(keepAlive)

                // Two byte integer
                remainingLength -= 2

            default:
                break
            }

            guard let newProperty = property else {
                throw MQTTCodingError.malformedPacket
            }

            properties.append(newProperty)
        }
        return properties
    }
}
