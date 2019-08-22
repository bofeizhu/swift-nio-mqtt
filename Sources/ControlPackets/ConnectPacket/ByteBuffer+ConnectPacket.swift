//
//  ByteBuffer+ConnectPacket.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 8/14/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

import NIO

extension ByteBuffer {

    @discardableResult
    mutating func write(_ connectPacket: ConnectPacket) throws -> Int {

        var bytesWritten = 0

        // MARK: Fixed Header

        bytesWritten += try write(connectPacket.fixedHeader)

        // MARK: Variable Header

        let variableHeader = connectPacket.variableHeader

        bytesWritten += try writeMQTTString(variableHeader.protocolName)
        bytesWritten += writeByte(variableHeader.protocolVersion)
        bytesWritten += writeByte(variableHeader.connectFlags.rawValue)
        bytesWritten += writeInteger(variableHeader.keepAlive)
        bytesWritten += try write(variableHeader.properties)

        // MARK: Payload

        let payload = connectPacket.payload

        

        return bytesWritten
    }
}
