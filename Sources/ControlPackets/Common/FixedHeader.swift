//
//  FixedHeader.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 6/17/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

import NIO

protocol FixedHeaderType {
    var packetTypeRawValue: UInt8 { get }
    var reserveRawValue: UInt8 { get }
}

extension FixedHeaderType {
    var byte: UInt8 {
        return (packetTypeRawValue << 4) | reserveRawValue
    }
}

enum ReservedFixedHeader: UInt8 {
    /// Reserved
    case reserved = 0

    /// Connection request
    case connect = 1

    /// Connect acknowledgment
    case connAck = 2

    /// Publish acknowledgment (QoS 1)
    case pubAck = 4

    /// Publish received (QoS 2 delivery part 1)
    case pubRec = 5

    /// Publish release (QoS 2 delivery part 2)
    case pubRel = 6

    /// Publish complete (QoS 2 delivery part 3)
    case pubComp = 7

    /// Subscribe request
    case subscribe = 8

    /// Subscribe acknowledgment
    case subAck = 9

    /// Unsubscribe request
    case unsubscribe = 10

    /// Unsubscribe acknowledgment
    case unsubAck = 11

    /// PING request
    case pingReq = 12

    /// PING response
    case pingResp = 13

    /// Disconnect notification
    case disconnect = 14

    /// Authentication exchange
    case auth = 15
}

extension ReservedFixedHeader: Equatable {}

extension ReservedFixedHeader: FixedHeaderType {
    var packetTypeRawValue: UInt8 {
        return self.rawValue
    }

    var reserveRawValue: UInt8 {
        switch self {

        case .reserved,
             .connect,
             .connAck,
             .pubAck,
             .pubRec,
             .pubComp,
             .subAck,
             .unsubAck,
             .pingReq,
             .pingResp,
             .disconnect,
             .auth:
            return 0

        case .pubRel, .subscribe, .unsubscribe:
            return 2
        }
    }
}

struct PublishFixedHeader {

    let dup: Bool
    let qos: QoS
    let retain: Bool

    init?(reserve: UInt8) {
        guard let qos = QoS(rawValue: (reserve >> 1) & 0b11) else { return nil }
        let dup = ((reserve >> 3) & 1) == 1
        let retain = (reserve & 1) == 1
        self.init(dup: dup, qos: qos, retain: retain)
    }

    init(dup: Bool, qos: QoS, retain: Bool) {
        self.dup = dup
        self.qos = qos
        self.retain = retain
    }
}

extension PublishFixedHeader: FixedHeaderType {
    var packetTypeRawValue: UInt8 {
        return UInt8(3)
    }

    var reserveRawValue: UInt8 {
        let bit0: UInt8 = retain ? 1 : 0
        let bit12 = qos.rawValue
        let bit3: UInt8 = dup ? 1 : 0
        return (bit3 << 3) | (bit12 << 1) | bit0
    }
}

/// MQTT Control Packet Fixed Header
struct FixedHeader {

//    /// MQTT Control Packet type
//    let type: ControlPacketType
//
//    /// MQTT Control Packet Flags
//    let flags: FixedHeaderFlags

    /// MQTT Control Packet Type & Flags
    let type: FixedHeaderType

    /// Remaining Length
    ///
    /// The Remaining Length is a Variable Byte Integer that represents the number of bytes remaining within
    /// the current Control Packet, including data in the Variable Header and the Payload.
    /// The Remaining Length does not include the bytes used to encode the Remaining Length.
    /// The packet size is the total number of bytes in an MQTT Control Packet, this is equal to the length of
    /// the Fixed Header plus the Remaining Length.
    let remainingLength: VInt

    var reservedType: ReservedFixedHeader? {
        guard let reservedType = type as? ReservedFixedHeader else { return nil }
        return reservedType
    }

//    init(type: ControlPacketType, flags: FixedHeaderFlags, remainingLength: Int) {
//        self.type = type
//        self.flags = flags
//        self.remainingLength = VInt(value: UInt(remainingLength))
//    }
//
//    fileprivate init(type: ControlPacketType, flags: FixedHeaderFlags, remainingLength: VInt) {
//        self.type = type
//        self.flags = flags
//        self.remainingLength = remainingLength
//    }

    init(reservedType type: ReservedFixedHeader, remainingLength: Int) {
        self.init(type: type, remainingLength: remainingLength)
    }

    init(type: FixedHeaderType, remainingLength: Int) {
        self.init(type: type, remainingLength: VInt(value: UInt(remainingLength)))
    }

    fileprivate init(type: FixedHeaderType, remainingLength: VInt) {
        self.type = type
        self.remainingLength = remainingLength
    }

    static func construct(rawValue: UInt8, reserve: UInt8, remainingLength: VInt) throws -> FixedHeader {
        guard let type = FixedHeader.constructHeaderType(rawValue: rawValue, reserve: reserve) else {
            throw MQTTCodingError.malformedPacket
        }
        return FixedHeader(type: type, remainingLength: remainingLength)
    }

    private static func constructHeaderType(rawValue: UInt8, reserve: UInt8) -> FixedHeaderType? {
        if rawValue == 3 {
            return PublishFixedHeader(reserve: reserve)
        }
        return ReservedFixedHeader(rawValue: rawValue)
    }

//    private func validate(reserve: UInt8) -> Bool {
//        if type as? PublishFixedHeader != nil {
//            return true
//        }
//        if type.reserveRawValue == reserve {
//            return true
//        }
//        return false
//    }

//    static func makeReservedFixHeader(
//        of type: ControlPacketType,
//        withRemainingLength remainingLength: Int
//    ) -> FixedHeader {
//
//        assert(type != .publish, "Publish Packet doesn't have reserved flags.")
//
//        let flagsValue = FixedHeaderFlags.reservedFlagsValue(of: type)
//        let flags = FixedHeaderFlags.reserved(value: flagsValue)
//
//        return FixedHeader(type: type, flags: flags, remainingLength: remainingLength)
//    }
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

        do {
            let rawValue = headerByte >> 4
            let reserve = headerByte & 0xF
            return try FixedHeader.construct(rawValue: rawValue, reserve: reserve, remainingLength: remainingLength)
        } catch {
            throw error
        }

//        if
//            let type = ControlPacketType(rawValue: headerByte >> 4),
//            let flags = FixedHeaderFlags(type: type, value: headerByte & 0xF),
//            type.validate(flags) {
//            return FixedHeader(type: type, flags: flags, remainingLength: remainingLength)
//        } else {
//            throw MQTTCodingError.malformedPacket
//        }
    }

    /// Read a fixed header off this `ByteBuffer`,
    /// move the reader index forward by the fixed header's byte size and return the result.
    ///
    /// - Returns: A fixed header or `nil` if there aren't enough bytes readable.
    /// - Throws: A MQTT coding error when fixed header is malformed.
    mutating func readFixedHeader() throws -> FixedHeader? {
        guard let fixedHeader = try getFixedHeader(at: readerIndex) else { return nil }
        moveReaderIndex(forwardBy: fixedHeader.remainingLength.mqttByteCount + 1)
        return fixedHeader
    }

    /// Write a fixed header into this `ByteBuffer`, moving the writer index forward appropriately.
    ///
    /// - Parameter fixedHeader: The fixed header to write.
    /// - Returns: The number of bytes written.
    /// - Throws: A MQTT coding error when fixed header is malformed.
    mutating func write(_ fixedHeader: FixedHeader) throws -> Int {
//        let byte = (fixedHeader.type.rawValue << 4) | fixedHeader.flags.value
        var bytesWritten = writeByte(fixedHeader.type.byte)
        bytesWritten += try writeVariableByteInteger(fixedHeader.remainingLength)
        return bytesWritten
    }
}
