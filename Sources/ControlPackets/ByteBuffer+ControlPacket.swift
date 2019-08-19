//
//  ByteBuffer+ControlPacket.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 8/15/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

import NIO

extension ByteBuffer {

    mutating func readControlPacket(with fixedHeader: FixedHeader) throws -> ControlPacket {
        switch fixedHeader.type {

        case .connAck:
            let packet = try readConnAckPacket(with: fixedHeader)
            return .connAck(packet: packet)

        default:
            throw MQTTCodingError.malformedPacket
        }
    }
}
