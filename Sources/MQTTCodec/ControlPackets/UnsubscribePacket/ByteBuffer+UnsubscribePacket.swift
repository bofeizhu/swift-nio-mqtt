//
//  ByteBuffer+UnsubscribePacket.swift
//  MQTTCodec
//
//  Created by Bofei Zhu on 8/28/19.
//  Copyright © 2019 Bofei Zhu. All rights reserved.
//

import NIO

extension ByteBuffer {

    mutating func write(_ packet: UnsubscribePacket) throws -> Int {

        var byteWritten = try write(packet.fixedHeader)

        // MARK: Write Variable Header

        let variableHeader = packet.variableHeader
        byteWritten += writeInteger(variableHeader.packetIdentifier)
        byteWritten += try write(variableHeader.properties)

        // MARK: Write Payload

        let topicFilters = packet.payload.topicFilters
        for topicFilter in topicFilters {
            byteWritten += try writeMQTTString(topicFilter)
        }

        return byteWritten
    }
}
