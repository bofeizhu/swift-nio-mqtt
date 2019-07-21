//
//  ByteBuffer+DataTypes.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 6/17/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

import NIO

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
            let bytes = readBytes(length: Int(length))
        else { return nil }
        return Data(bytes)
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
}
