//
//  ByteBuffer+SubscribePacket.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 8/28/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

import NIO

extension ByteBuffer {

    mutating func write(_ packet: SubscribePacket) throws -> Int {

        var byteWritten = try write(packet.fixedHeader)

        let variableHeader = packet.variableHeader
        byteWritten += writeInteger(variableHeader.packetIdentifier)
        byteWritten += try write(variableHeader.properties)

        let topicFilters = packet.payload.topicFilters
        for topicFilter in topicFilters {
            byteWritten += try write(topicFilter)
        }
        
        return byteWritten
    }

    private mutating func write(_ topicFilter: SubscribePacket.TopicFilter) throws -> Int {

        var byteWritten = try writeMQTTString(topicFilter.topic)
        byteWritten += writeInteger(topicFilter.options.rawValue)

        return  byteWritten
    }
}
