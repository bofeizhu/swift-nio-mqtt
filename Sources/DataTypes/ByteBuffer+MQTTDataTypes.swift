//
//  ByteBuffer+MQTTDataTypes.swift
//  SwiftNIOMQTT
//
//  Created by Bofei Zhu on 6/17/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

import NIO

extension ByteBuffer {
    
    // MARK: MQTT UTF-8 Encoded String APIs
    
    /// Read the UInt16 `length` field that gives the number of bytes in a UTF-8 encoded string itself.
    /// Then, read `length` bytes off this `ByteBuffer`, decoding it as `String` using the UTF-8 encoding.
    /// Move the reader index forward by `length`.
    ///
    /// - Returns: A `String` value deserialized from this `ByteBuffer` or `nil` if it's malformed.
    mutating func readMQTTString() -> String? {
        guard let length: UInt16 = readInteger() else {
            return nil
        }
        return readString(length: Int(length))
    }
    
    /// Write UTF-8 encoded string into this `ByteBuffer` prefixed with the UInt16 `length`, moving the writer index forward appropriately.
    ///
    /// - Parameter string: The string to serialize.
    /// - Returns: The number of bytes written.
    /// - Throws: A MQTT encoding error when string is too long (the maximum size of a UTF-8 Encoded String in MQTT is 65,535 bytes).
    @discardableResult
    mutating func writeMQTTString(_ string: String) throws -> Int {
        let length = string.utf8.count
        guard length <= UInt16.max else {
            throw MQTTEncodingError.utf8StringTooLong
        }
        var byteWritten = writeInteger(UInt16(length))
        byteWritten += writeString(string)
        return byteWritten
    }
    
    // MARK: Variable Byte Integer APIs
    
    /// Read a variable byte integer off this `ByteBuffer`,
    /// move the reader index forward by the integer's byte size and return the result.
    ///
    /// - Returns: A variable byte integer value deserialized from this `ByteBuffer` or `nil` if there aren't enough bytes readable.
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
    
    /// Write `VInt` into this `ByteBuffer`, moving the writer index forward appropriately.
    ///
    /// - Parameter integer: The integer to serialize.
    /// - Returns: The number of bytes written.
    @discardableResult
    mutating func writeVariableByteInteger(_ integer: VInt) -> Int {
        return writeBytes(integer.bytes)
    }
    
    // MARK: Helpers
    
    /// Read 1 byte off this `ByteBuffer`, move the reader index forward by 1 byte and return the result
    ///
    /// - Returns:  A `UInt8` value containing 1 byte or `nil` if there aren't any byte readable.
    mutating func readByte() -> UInt8? {
        guard let bytes = readBytes(length: 1) else {
            return nil
        }
        return bytes[0]
    }
}
