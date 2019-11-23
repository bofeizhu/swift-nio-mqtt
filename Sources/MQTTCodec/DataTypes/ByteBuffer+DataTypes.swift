//
//  ByteBuffer+DataTypes.swift
//  MQTTCodec
//
//  Created by Bofei Zhu on 6/17/19.
//  Copyright © 2019 Bofei Zhu. All rights reserved.
//

import NIO
import Foundation
import NIOFoundationCompat

extension ByteBuffer {

    // MARK: MQTT UTF-8 Encoded String APIs

    /// Read the UInt16 `length` field that gives the number of bytes in the UTF-8 encoded string itself.
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

    /// Write UTF-8 encoded string into this `ByteBuffer` prefixed with its UInt16 `length`,
    /// moving the writer index forward appropriately.
    ///
    /// - Parameter string: The string to serialize.
    /// - Returns: The number of bytes written.
    /// - Throws: A MQTT coding error when string is too long
    ///     (the maximum size of an UTF-8 Encoded String in MQTT is 65,535 bytes).
    @discardableResult
    mutating func writeMQTTString(_ string: String) throws -> Int {
        let length = string.utf8.count
        guard length <= UInt16.max else {
            throw MQTTCodingError.utf8StringTooLong
        }
        return writeInteger(UInt16(length)) + writeString(string)
    }

    // MARK: Binary Data APIs

    /// Read the UInt16 `length` field that gives the number of bytes in the binary data itself.
    /// Then, read `length` bytes off this `ByteBuffer`. Move the reader index forward by `length`.
    ///
    /// - Returns: A binary data value deserialized from this `ByteBuffer` or `nil` if it's malformed.
    mutating func readMQTTBinaryData() -> Data? {
        guard
            let length: UInt16 = readInteger(),
            let data = readData(length: Int(length))
        else { return nil }
        return data
    }

    /// Write the binary data into this `ByteBuffer` prefixed with its UInt16 `length`,
    /// moving the writer index forward appropriately.
    ///
    /// - Parameter data: The binary data to write.
    /// - Returns: The number of bytes written.
    /// - Throws: A MQTT coding error when binary data is too large
    ///     (the maximum size of binary data in MQTT is 65,535 bytes).
    @discardableResult
    mutating func writeMQTTBinaryData(_ data: Data) throws -> Int {
        guard data.count <= UInt16.max else {
            throw MQTTCodingError.binaryDataTooLong
        }
        return writeInteger(UInt16(data.count)) + writeBytes(data)
    }

    // MARK: UTF-8 String Pair

    /// Read a string pair off this `ByteBuffer`, move the reader index forward and return the result.
    ///
    /// - Returns: A string pair value deserialized from this `ByteBuffer` or `nil` if it's malformed.
    mutating func readStringPair() -> StringPair? {
        guard
            let name = readMQTTString(),
            let value = readMQTTString()
        else { return nil }
        return StringPair(name: name, value: value)
    }

    /// Write UTF-8 String into this `ByteBuffer` prefixed with its UInt16 `length`,
    /// moving the writer index forward appropriately.
    ///
    /// - Parameter stringPair: The string pair to serialize.
    /// - Returns: The number of bytes written.
    /// - Throws: A MQTT coding error when strings are too long
    ///     (the maximum size of an UTF-8 Encoded String in MQTT is 65,535 bytes).
    @discardableResult
    mutating func write(_ stringPair: StringPair) throws -> Int {
        let nameLength = try writeMQTTString(stringPair.name)
        let valueLength = try writeMQTTString(stringPair.value)
        return nameLength + valueLength
    }

    // MARK: Helpers

    /// Get 1 byte at `index` from this `ByteBuffer`. Does not move the reader index.
    /// The selected bytes must be readable or else `nil` will be returned.
    ///
    /// - Parameter index: The index of the byte in the `ByteBuffer`.
    /// - Returns: A `UInt8` value containing 1 byte or `nil` if there aren't any byte readable.
    func getByte(at index: Int) -> UInt8? {
        return getInteger(at: index)
    }

    /// Read 1 byte off this `ByteBuffer`, move the reader index forward by 1 byte and return the result
    ///
    /// - Returns:  A `UInt8` value containing 1 byte or `nil` if there aren't any byte readable.
    mutating func readByte() -> UInt8? {
        return readInteger()
    }

    /// Write 1 byte into this `ByteBuffer`, moving the writer index forward appropriately.
    ///
    /// - Parameter byte: The byte to write.
    /// - Returns: The number of bytes written (always 1).
    @discardableResult
    mutating func writeByte(_ byte: UInt8) -> Int {
        return writeInteger(byte)
    }

    /// Read a boolean byte off this `ByteBuffer`, move the reader index forward by 1 byte and return the result
    ///
    /// - Returns: A boolean value or `nil` if there aren't any byte readable.
    /// - Throws: A MQTT coding error when byte is neither 0 nor 1.
    mutating func readBool() throws -> Bool? {
        guard let byte = readByte() else {
            return nil
        }

        if byte == 0 {
            return false
        } else if byte == 1 {
            return true
        }

        throw MQTTCodingError.malformedPacket
    }

    /// Write a boolean byte into this `ByteBuffer`, moving the writer index forward 1 byte.
    ///
    /// - Parameter bool: The boolean to write.
    /// - Returns: The number of bytes written (always 1).
    @discardableResult
    mutating func write(_ bool: Bool) -> Int {
        if bool {
            return writeByte(1)
        } else {
            return writeByte(0)
        }
    }
}
