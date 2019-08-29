//
//  ByteBuffer+PubRecPacket.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 8/14/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

import NIO

extension ByteBuffer {

    mutating func readPubRecPacket(with fixedHeader: FixedHeader) throws -> PubRecPacket {

        let packetIdentifier = try readPacketIdentifier()
        let reasonCode: PubRecPacket.ReasonCode = try readReasonCode()
        let properties = try readProperties()

        let variableHeader = PubRecPacket.VariableHeader(
            packetIdentifier: packetIdentifier,
            reasonCode: reasonCode,
            properties: properties)

        return PubRecPacket(fixedHeader: fixedHeader, variableHeader: variableHeader)
    }

    mutating func write(_ packet: PubRecPacket) throws -> Int {

        var byteWritten = try write(packet.fixedHeader)

        let variableHeader = packet.variableHeader
        byteWritten += writeInteger(variableHeader.packetIdentifier)
        byteWritten += writeInteger(variableHeader.reasonCode.rawValue)
        byteWritten += try write(variableHeader.properties)

        return byteWritten
    }
}
