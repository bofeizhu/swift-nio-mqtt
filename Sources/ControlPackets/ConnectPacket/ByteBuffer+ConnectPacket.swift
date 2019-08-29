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
    mutating func write(_ packet: ConnectPacket) throws -> Int {

        var bytesWritten = try write(packet.fixedHeader)
        bytesWritten += try write(packet.variableHeader)
        bytesWritten += try write(packet.payload)

        return bytesWritten
    }

    private mutating func write(_ variableHeader: ConnectPacket.VariableHeader) throws -> Int {

        var bytesWritten = try writeMQTTString(variableHeader.protocolName)
        bytesWritten += writeByte(variableHeader.protocolVersion)
        bytesWritten += writeByte(variableHeader.connectFlags.rawValue)
        bytesWritten += writeInteger(variableHeader.keepAlive)
        bytesWritten += try write(variableHeader.properties)

        return bytesWritten
    }

    private mutating func write(_ payload: ConnectPacket.Payload) throws -> Int {

        var bytesWritten = try writeMQTTString(payload.clientId)

        if let willMessage = payload.willMessage {
            bytesWritten += try write(willMessage.properties)
            bytesWritten += try writeMQTTString(willMessage.topic)
            bytesWritten += try writeMQTTBinaryData(willMessage.payload)
        }

        if let username = payload.username {
            bytesWritten += try writeMQTTString(username)
        }

        if let password = payload.password {
            bytesWritten += try writeMQTTBinaryData(password)
        }

        return payload.mqttByteCount
    }
}
