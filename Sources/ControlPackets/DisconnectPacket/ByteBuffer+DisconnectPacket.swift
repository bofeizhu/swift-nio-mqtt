//
//  ByteBuffer+DisconnectPacket.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 8/14/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
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
}
