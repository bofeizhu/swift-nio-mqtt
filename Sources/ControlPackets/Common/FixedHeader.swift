//
//  FixedHeader.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 6/17/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

import NIO

/// MQTT Control Packet Fixed Header
struct FixedHeader {

    /// MQTT Control Packet type
    let type: ControlPacketType

    /// MQTT Control Packet Flags
    let flags: FixedHeaderFlags

    /// Remaining Length
    ///
    /// The Remaining Length is a Variable Byte Integer that represents the number of bytes remaining within
    /// the current Control Packet, including data in the Variable Header and the Payload.
    /// The Remaining Length does not include the bytes used to encode the Remaining Length.
    /// The packet size is the total number of bytes in an MQTT Control Packet, this is equal to the length of
    /// the Fixed Header plus the Remaining Length.
    let remainingLength: VInt

    init(type: ControlPacketType, flags: FixedHeaderFlags, remainingLength: Int) {
        self.type = type
        self.flags = flags
        self.remainingLength = VInt(value: UInt(remainingLength))
    }

    fileprivate init(type: ControlPacketType, flags: FixedHeaderFlags, remainingLength: VInt) {
        self.type = type
        self.flags = flags
        self.remainingLength = remainingLength
    }

    static func makeReservedFixHeader(
        of type: ControlPacketType,
        withRemainingLength remainingLength: Int
    ) -> FixedHeader {

        assert(type != .publish, "Publish Packet doesn't have reserved flags.")

        let flagsValue = FixedHeaderFlags.reservedFlagsValue(of: type)
        let flags = FixedHeaderFlags.reserved(value: flagsValue)

        return FixedHeader(type: type, flags: flags, remainingLength: remainingLength)
    }
}

// MARK: - ByteBuffer Extension

extension ByteBuffer {

    /// Get a fixed header off this `ByteBuffer`. Does not move the reader index.
    ///
    /// - Parameter index: The starting index of the bytes for the integer into the `ByteBuffer`.
    /// - Returns: A fixed header or `nil` if there aren't enough bytes readable.
    /// - Throws: A MQTT coding error when fixed header is malformed.
    func getFixedHeader(at index: Int) throws -> FixedHeader? {
        guard
            let headerByte = getByte(at: index),
            let remainingLength = try getVariableByteInteger(at: index + 1)
            else { return nil }

        guard
            let type = ControlPacketType(rawValue: headerByte >> 4),
            FixedHeaderFlags.validate(type: type, value: headerByte & 0xF),
            let flags = FixedHeaderFlags(type: type)
            else { throw MQTTCodingError.malformedPacket }

        return FixedHeader(type: type, flags: flags, remainingLength: remainingLength)
    }

    /// Read a fixed header off this `ByteBuffer`,
    /// move the reader index forward by the fixed header's byte size and return the result.
    ///
    /// - Returns: A fixed header or `nil` if there aren't enough bytes readable.
    /// - Throws: A MQTT coding error when fixed header is malformed.
    mutating func readFixedHeader() throws -> FixedHeader? {
        guard let fixedHeader = try getFixedHeader(at: readerIndex) else {
            return nil
        }
        moveReaderIndex(forwardBy: fixedHeader.remainingLength.mqttByteCount + 1)
        return fixedHeader
    }

    /// Write a fixed header into this `ByteBuffer`, moving the writer index forward appropriately.
    ///
    /// - Parameter fixedHeader: The fixed header to write.
    /// - Returns: The number of bytes written.
    /// - Throws: A MQTT coding error when fixed header is malformed.
    mutating func write(_ fixedHeader: FixedHeader) throws -> Int {
        let byte = (fixedHeader.type.rawValue << 4) | fixedHeader.flags.value
        var bytesWritten = writeByte(byte)
        bytesWritten += try writeVariableByteInteger(fixedHeader.remainingLength)
        return bytesWritten
    }
}
