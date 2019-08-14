//
//  ByteBuffer+Property.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 8/11/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

import NIO

// swiftlint:disable cyclomatic_complexity
extension ByteBuffer {

    @discardableResult
    mutating func write(_ properties: [Property]) throws -> Int {
        return 0
    }

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

            let property = try readProperty(of: identifier)
            properties.append(property)
            remainingLength -= property.byteCount
        }
        return properties
    }

    // swiftlint:disable:next function_body_length
    private mutating func readProperty(of identifier: PropertyIdentifier) throws -> Property {
        switch identifier {
        case .payloadFormatIndicator:
            guard let isUTF8Encoded = try readBool() else {
                throw MQTTCodingError.malformedPacket
            }
            return .payloadFormatIndicator(isUTF8Encoded)

        case .messageExpiryInterval:
            guard let interval: UInt32 = readInteger() else {
                throw MQTTCodingError.malformedPacket
            }
            return .messageExpiryInterval(interval)

        case .contentType:
            guard let contentType = readMQTTString() else {
                throw MQTTCodingError.malformedPacket
            }
            return .contentType(contentType)

        case .responseTopic:
            guard let topic = readMQTTString() else {
                throw MQTTCodingError.malformedPacket
            }
            return .responseTopic(topic)

        case .correlationData:
            guard let data = readMQTTBinaryData() else {
                throw MQTTCodingError.malformedPacket
            }
            return .correlationData(data)

        case .subscriptionIdentifier:
            guard let identifier = try readVariableByteInteger() else {
                throw MQTTCodingError.malformedPacket
            }
            return .subscriptionIdentifier(identifier)

        case .sessionExpiryInterval:
            guard let interval: UInt32 = readInteger() else {
                throw MQTTCodingError.malformedPacket
            }
            return .sessionExpiryInterval(interval)

        case .assignedClientIdentifier:
            guard let identifier = readMQTTString() else {
                throw MQTTCodingError.malformedPacket
            }
            return .assignedClientIdentifier(identifier)

        case .serverKeepAlive:
            guard let keepAlive: UInt16 = readInteger() else {
                throw MQTTCodingError.malformedPacket
            }
            return .serverKeepAlive(keepAlive)

        case .authenticationMethod:
            guard let method = readMQTTString() else {
                throw MQTTCodingError.malformedPacket
            }
            return .authenticationMethod(method)

        case .authenticationData:
            guard let data = readMQTTBinaryData() else {
                throw MQTTCodingError.malformedPacket
            }
            return .authenticationData(data)

        case .requestProblemInformation, .willDelayInterval, .requestResponseInformation:
            // Only client to server, no need to decode
            throw MQTTCodingError.malformedPacket

        case .responseInformation:
            guard let information = readMQTTString() else {
                throw MQTTCodingError.malformedPacket
            }
            return .responseInformation(information)

        case .serverReference:
            guard let reference = readMQTTString() else {
                throw MQTTCodingError.malformedPacket
            }
            return .serverReference(reference)

        case .reasonString:
            guard let string = readMQTTString() else {
                throw MQTTCodingError.malformedPacket
            }
            return .reasonString(string)

        case .receiveMaximum:
            guard let max: UInt16 = readInteger() else {
                throw MQTTCodingError.malformedPacket
            }
            return .receiveMaximum(max)

        case .topicAliasMaximum:
            guard let max: UInt16 = readInteger() else {
                throw MQTTCodingError.malformedPacket
            }
            return .topicAliasMaximum(max)

        case .topicAlias:
            guard let alias: UInt16 = readInteger() else {
                throw MQTTCodingError.malformedPacket
            }
            return .topicAlias(alias)

        case .maximumQoS:
            guard
                let qosValue = readByte(),
                let qos = QoS(rawValue: qosValue)
            else {
                throw MQTTCodingError.malformedPacket
            }
            return .maximumQoS(qos)

        case .retainAvailable:
            guard let available = try readBool() else {
                throw MQTTCodingError.malformedPacket
            }
            return .retainAvailable(available)

        case .userProperty:
            guard let property = readStringPair() else {
                throw MQTTCodingError.malformedPacket
            }
            return .userProperty(property)

        case .maximumPacketSize:
            guard let size: UInt32 = readInteger() else {
                throw MQTTCodingError.malformedPacket
            }
            return .maximumPacketSize(size)

        case .wildcardSubscriptionAvailable:
            guard let available = try readBool() else {
                throw MQTTCodingError.malformedPacket
            }
            return .wildcardSubscriptionAvailable(available)

        case .subscriptionIdentifierAvailable:
            guard let available = try readBool() else {
                throw MQTTCodingError.malformedPacket
            }
            return .subscriptionIdentifierAvailable(available)

        case .sharedSubscriptionAvailable:
            guard let available = try readBool() else {
                throw MQTTCodingError.malformedPacket
            }
            return .sharedSubscriptionAvailable(available)
        }
    }
}
