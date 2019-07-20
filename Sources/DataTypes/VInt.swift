//
//  VInt.swift
//  SwiftNIOMQTT
//
//  Created by Bofei Zhu on 6/13/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
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
    init(value: UInt) {
        assert(value <= 268435455, "Value too large. The maximum number of bytes in the VInt field is four.")

        self.value = value
        var remainingValue = value
        var bytes: [UInt8] = []
        repeat {
            var byte = UInt8(remainingValue % 128)
            remainingValue /= 128
            if remainingValue > 0 {
                byte |= 128
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
        value = UInt(firstByte & 127)
        bytes = [firstByte]
        hasFollowing = firstByte & 128 != 0
        multiplier = 128
    }

    /// Init with leading bytes and next byte
    ///
    /// - Parameters:
    ///   - leading: The leading varible byte integer
    ///   - nextByte: The next byte of varible byte integer
    fileprivate init(leading: VInt, nextByte: UInt8) {
        assert(leading.hasFollowing, "The leading variable byte integer doesn't have following byte.")
        assert(leading.bytes.count < 4, "Value too large. The maximum number of bytes in the VInt field is four.")

        guard leading.hasFollowing else {
            self = leading
            return
        }
        value = leading.value + UInt(nextByte & 127) * leading.multiplier
        bytes = leading.bytes + [nextByte]
        hasFollowing = nextByte & 128 != 0
        multiplier = leading.multiplier * 128
    }
}

extension VInt: Equatable {
    static func == (lhs: VInt, rhs: VInt) -> Bool {
        return lhs.value == rhs.value && lhs.bytes == rhs.bytes
    }
}

extension ByteBuffer {

    // MARK: Variable Byte Integer APIs

    /// Read a variable byte integer off this `ByteBuffer`,
    /// move the reader index forward by the integer's byte size and return the result.
    ///
    /// - Returns: A variable byte integer value deserialized from this `ByteBuffer` or `nil`
    ///     if there aren't enough bytes readable.
    mutating func readVariableByteInteger() -> VInt? {
        guard let firstByte = readByte() else {
            return nil
        }
        var integer = VInt(firstByte: firstByte)
        while integer.hasFollowing {
            guard let nextByte = readByte() else {
                return nil
            }
            integer = VInt(leading: integer, nextByte: nextByte)
        }
        return integer
    }

    /// Write the variable byte integer into this `ByteBuffer`, moving the writer index forward appropriately.
    ///
    /// - Parameter integer: The integer to serialize.
    /// - Returns: The number of bytes written.
    @discardableResult
    mutating func writeVariableByteInteger(_ integer: VInt) -> Int {
        return writeBytes(integer.bytes)
    }
}
