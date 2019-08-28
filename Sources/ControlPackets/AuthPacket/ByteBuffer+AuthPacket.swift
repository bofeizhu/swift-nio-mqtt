//
//  ByteBuffer+AuthPacket.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 8/21/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

import NIO

extension ByteBuffer {

    mutating func readAuthPacket(with fixedHeader: FixedHeader) throws -> AuthPacket {

        let reasonCode: AuthPacket.ReasonCode = try readReasonCode()
        let properties = try readProperties()

        let variableHeader = AuthPacket.VariableHeader(
            reasonCode: reasonCode,
            properties: properties)

        return AuthPacket(fixedHeader: fixedHeader, variableHeader: variableHeader)
    }

    mutating func write(_ packet: AuthPacket) throws -> Int {

        var byteWritten = try write(packet.fixedHeader)

        let variableHeader = packet.variableHeader
        byteWritten += writeInteger(variableHeader.reasonCode.rawValue)
        byteWritten += try write(variableHeader.properties)

        return byteWritten
    }
}
