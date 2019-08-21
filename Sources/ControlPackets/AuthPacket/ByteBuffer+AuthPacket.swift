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
}
