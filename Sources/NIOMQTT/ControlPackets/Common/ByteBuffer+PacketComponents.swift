//
//  ByteBuffer+ReasonCode.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 8/20/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

import NIO

extension ByteBuffer {
    mutating func readPacketIdentifier() throws -> UInt16 {
        guard let packetIdentifier: UInt16 = readInteger() else {

            // FIXME: Should throw an internal error.
            //      Since we check remaining length before read packet variable header.
            throw MQTTCodingError.malformedPacket
        }

        return packetIdentifier
    }

    mutating func readReasonCode<T: RawRepresentable>() throws -> T where T.RawValue == ReasonCodeValue {
        guard
            let byte = readByte(),
            let reasonCode = T(rawValue: byte)
        else {
            throw MQTTCodingError.malformedPacket
        }

        return reasonCode
    }

    mutating func readReasonCodeList<T: RawRepresentable>(length: Int) throws -> [T]
    where T.RawValue == ReasonCodeValue {
        guard let bytes = readBytes(length: length) else {
            throw MQTTCodingError.malformedPacket
        }

        let list = try bytes.map { byte -> T in
            guard let reasonCode = T(rawValue: byte) else {
                throw MQTTCodingError.malformedPacket
            }
            return reasonCode
        }

        return list
    }
}
