//
//  ByteBuffer+DisconnectPacket.swift
//  MQTTCodec
//
//  Created by Bofei Zhu on 8/21/19.
//  Copyright © 2019 Bofei Zhu. All rights reserved.
//

import NIO

extension ByteBuffer {

    mutating func readDisconnectPacket(with fixedHeader: FixedHeader) throws -> DisconnectPacket {
        let reasonCode: DisconnectPacket.ReasonCode = try readReasonCode()
        let properties = try readProperties()

        let variableHeader = DisconnectPacket.VariableHeader(
            reasonCode: reasonCode,
            properties: properties)

        return DisconnectPacket(fixedHeader: fixedHeader, variableHeader: variableHeader)
    }

    mutating func write(_ packet: DisconnectPacket) throws -> Int {
        var byteWritten = try write(packet.fixedHeader)

        let variableHeader = packet.variableHeader
        byteWritten += writeInteger(variableHeader.reasonCode.rawValue)
        byteWritten += try write(variableHeader.properties)

        return byteWritten
    }
}
