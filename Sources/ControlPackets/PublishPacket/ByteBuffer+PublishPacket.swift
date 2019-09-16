//
//  ByteBuffer+PublishPacket.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 8/14/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

import NIO

extension ByteBuffer {

    // MARK: - Read Publish Packet

    mutating func readPublishPacket(with fixedHeader: FixedHeader) throws -> PublishPacket {

        // MARK: Read variable header

        var variableHeaderLength = 0

        guard let topicName = readMQTTString() else {
            throw MQTTCodingError.malformedPacket
        }

        variableHeaderLength += topicName.mqttByteCount

        var packetIdentifier: UInt16?

        guard let publishType = fixedHeader.type as? PublishFixedHeaderType else {
            throw MQTTCodingError.malformedPacket
        }

        if publishType.qos != .level0 {
            guard let identifier: UInt16 = readInteger() else { throw MQTTCodingError.malformedPacket }
            packetIdentifier = identifier
        }

        variableHeaderLength += (packetIdentifier == nil) ? 0 : 2

        let properties = try readProperties()

        variableHeaderLength += properties.mqttByteCount

        let variableHeader = PublishPacket.VariableHeader(
            topicName: topicName,
            packetIdentifier: packetIdentifier,
            properties: properties)

        // MARK: Read payload

        let remainingLength = Int(fixedHeader.remainingLength.value)
        let payloadLength = remainingLength - variableHeaderLength
        guard
            let payload = readPublishPayload(length: payloadLength, isUTF8Encoded: properties.isPayloadUTF8Encoded),
            let publishPacket = PublishPacket(
                fixedHeader: fixedHeader,
                variableHeader: variableHeader,
                payload: payload)
        else { throw MQTTCodingError.malformedPacket }

        return publishPacket
    }

    // MARK: Write Publish Packet

    @discardableResult
    mutating func write(_ packet: PublishPacket) throws -> Int {

        var bytesWritten = try write(packet.fixedHeader)
        bytesWritten += try write(packet.variableHeader)
        bytesWritten += write(packet.payload)

        return bytesWritten
    }

    // MARK: - Variable Header I/O

    private mutating func write(_ variableHeader: PublishPacket.VariableHeader) throws -> Int {

        var bytesWritten = try writeMQTTString(variableHeader.topicName)
        if let packetIdentifier = variableHeader.packetIdentifier {
            bytesWritten += writeInteger(packetIdentifier)
        }
        bytesWritten += try write(variableHeader.properties)
        return bytesWritten
    }

    // MARK: - Payload I/O

    private mutating func readPublishPayload(length: Int, isUTF8Encoded: Bool = false) -> PublishPacket.Payload? {

        guard length > 0 else { return .empty }

        if isUTF8Encoded {
            guard let string = readString(length: length) else {
                return nil
            }
            return .utf8(stirng: string)
        } else {
            guard let data = readData(length: length) else {
                return nil
            }
            return .binary(data: data)
        }
    }

    private mutating func write(_ payload: PublishPacket.Payload) -> Int {

        switch payload {

        case let .binary(data):
            return writeBytes(data)

        case let .utf8(string):
            return writeString(string)

        case .empty:
            return 0
        }
    }
}
