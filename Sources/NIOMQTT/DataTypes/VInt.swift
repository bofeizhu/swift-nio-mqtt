//
//  VInt.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 6/13/19.
//  Copyright © 2019 Bofei Zhu. All rights reserved.
//

import NIO

/// Variable Byte Integer
///
/// The Variable Byte Integer is encoded using an encoding scheme which uses a single byte for values up to 127.
/// Larger values are handled as follows. The least significant seven bits of each byte encode the data,
/// and the most significant bit is used to indicate whether there are bytes following in the representation.
/// Thus, each byte encodes 128 values and a "continuation bit".
/// The maximum number of bytes in the Variable Byte Integer field is four.
/// The encoded value MUST use the minimum number of bytes necessary to represent the value.
struct VInt {
    let value: UInt
    let bytes: [UInt8]

    fileprivate let hasFollowing: Bool
    private let multiplier: UInt

    /// Init with integer value
    ///
    /// - Parameter value: The integer value of the variable byte integer
    /// - Complexity: O(*log(n)*)
    init(value: UInt) {
        assert(value <= VInt.max, "Value exceeds maximum integer value \(VInt.max)")

        self.value = value
        var remainingValue = value
        var bytes: [UInt8] = []
        repeat {
            var byte = UInt8(remainingValue % VInt.multiplier)
            remainingValue /= VInt.multiplier
            if remainingValue > 0 {
                byte |= UInt8(VInt.multiplier)
            }
            bytes.append(byte)
        } while remainingValue > 0

        self.bytes = bytes

        // No use
        hasFollowing = false
        multiplier = 0
    }

    /// Init with one byte
    ///
    /// - Parameter firstByte: The first byte of the variable byte integer
    fileprivate init(firstByte: UInt8) {
        value = UInt(firstByte & VInt.valueMask)
        bytes = [firstByte]
        hasFollowing = firstByte & VInt.followingMask != 0
        multiplier = VInt.multiplier
    }

    /// Init with leading bytes and next byte
    ///
    /// - Parameters:
    ///   - leading: The leading varible byte integer
    ///   - nextByte: The next byte of varible byte integer
    fileprivate init(leading: VInt, nextByte: UInt8) {
        assert(leading.hasFollowing, "The leading variable byte integer doesn't have following byte.")
        assert(
            leading.mqttByteCount < VInt.maxByteCount,
            "Value too large. The maximum number of bytes in the VInt field is four.")

        guard leading.hasFollowing else {
            self = leading
            return
        }
        value = leading.value + UInt(nextByte & VInt.valueMask) * leading.multiplier
        bytes = leading.bytes + [nextByte]
        hasFollowing = nextByte & VInt.followingMask != 0
        multiplier = leading.multiplier * VInt.multiplier
    }
}

// MARK: - ByteRepresentable

extension VInt: MQTTByteRepresentable {

    var mqttByteCount: Int {
        return bytes.count
    }
}

// MARK: - Equatable

extension VInt: Equatable {

    static func == (lhs: VInt, rhs: VInt) -> Bool {
        return lhs.value == rhs.value && lhs.bytes == rhs.bytes
    }
}

// MARK: - Constants

extension VInt {
    /// The maximum representable integer in VInt.
    static let max = 268435455

    /// The maximum number of bytes in VInt.
    static let maxByteCount = 4

    /// The bitmask for the least significant seven bits of a byte which encode the value.
    static fileprivate let valueMask: UInt8 = 127

    /// The bitmask for the most significant bit which is used to indicate whether there are bytes following.
    static fileprivate let followingMask: UInt8 = 128

    /// The multiplier for 1 byte.
    static fileprivate let multiplier: UInt = 128
}

// MARK: - ByteBuffer extensions

extension ByteBuffer {
    /// Get variable byte integer at `index` from this `ByteBuffer`. Does not move the reader index.
    /// The selected bytes must be readable or else `nil` will be returned.
    ///
    /// - Parameter index: The starting index of the bytes for the integer into the `ByteBuffer`.
    /// - Returns: A variable byte integer or `nil` if there aren't enough bytes readable.
    /// - Throws: A `malformedVariableByteInteger` Error if variable byte integer has more than 4 bytes.
    func getVariableByteInteger(at index: Int) throws -> VInt? {
        guard let firstByte = getByte(at: index) else {
            return nil
        }

        var integer = VInt(firstByte: firstByte)

        while integer.hasFollowing {
            guard integer.mqttByteCount < 4 else {
                throw MQTTCodingError.malformedVariableByteInteger
            }

            guard let nextByte = getByte(at: index + integer.mqttByteCount) else {
                // Need more bytes
                return nil
            }

            integer = VInt(leading: integer, nextByte: nextByte)
        }

        return integer
    }

    /// Read a variable byte integer off this `ByteBuffer`,
    /// move the reader index forward by the integer's byte size and return the result.
    ///
    /// - Returns: A variable byte integer value deserialized from this `ByteBuffer` or `nil`
    ///     if there aren't enough bytes readable.
    /// - Throws: A `malformedVariableByteInteger` Error if variable byte integer has more than 4 bytes.
    mutating func readVariableByteInteger() throws -> VInt? {
        guard let integer = try getVariableByteInteger(at: readerIndex) else {
            return nil
        }
        moveReaderIndex(forwardBy: integer.mqttByteCount)
        return integer
    }

    /// Write the variable byte integer into this `ByteBuffer`, moving the writer index forward appropriately.
    ///
    /// - Parameter integer: The integer to serialize.
    /// - Returns: The number of bytes written.
    /// - Throws: A `malformedVariableByteInteger` Error if variable byte integer has more than 4 bytes.
    @discardableResult
    mutating func writeVariableByteInteger(_ integer: VInt) throws -> Int {
        guard integer.mqttByteCount <= 4 else {
            throw MQTTCodingError.malformedVariableByteInteger
        }
        return writeBytes(integer.bytes)
    }
}
