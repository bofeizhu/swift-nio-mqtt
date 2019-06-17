//
//  ByteBuffer+MQTTDataTypes.swift
//  SwiftNIOMQTT
//
//  Created by Bofei Zhu on 6/17/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

import NIO

extension ByteBuffer {
    // MARK: VInt APIs
    
    /// Write `VInt` into this `ByteBuffer`, moving the writer index forward appropriately.
    ///
    /// - Parameter integer: The integer to serialize.
    /// - Returns: The number of bytes written.
    @discardableResult
    mutating func writeVariableByteInteger(_ integer: VInt) -> Int {
        return self.writeBytes(integer.bytes)
    }
    
    /// Read a variable byte integer off this `ByteBuffer`,
    /// move the reader index forward by the integer's byte size and return the result.
    ///
    /// - Returns: A variable byte integer value deserialized from this `ByteBuffer` or `nil` if there aren't enough bytes readable.
    mutating func readVariableByteInteger() -> VInt? {
        guard let firstByte = self.readByte() else {
            return nil
        }
        var integer = VInt(firstByte: firstByte)
        while integer.hasFollowing {
            guard let nextByte = self.readByte() else {
                return nil
            }
            integer = VInt(leading: integer, nextByte: nextByte)
        }
        return integer
    }
    
    // MARK: Helpers
    
    /// Read 1 byte off this `ByteBuffer`, move the reader index forward by 1 byte and return the result
    ///
    /// - Returns:  A `UInt8` value containing 1 byte or `nil` if there aren't any byte readable.
    @inlinable
    public mutating func readByte() -> UInt8? {
        guard let bytes = readBytes(length: 1) else {
            return nil
        }
        return bytes[0]
    }
}
