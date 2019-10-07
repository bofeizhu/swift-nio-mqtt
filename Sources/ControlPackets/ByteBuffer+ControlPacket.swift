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

        case .publish:
            let packet = try readPublishPacket(with: fixedHeader)
            return .publish(packet: packet)

        case .pubAck:
            let packet = try readPubAckPacket(with: fixedHeader, remainingLength: fixedHeader.remainingLength.value)
            return .pubAck(packet: packet)

        case .pubRec:
            let packet = try readPubRecPacket(with: fixedHeader)
            return .pubRec(packet: packet)

        case .pubRel:
            let packet = try readPubRelPacket(with: fixedHeader)
            return .pubRel(packet: packet)

        case .pubComp:
            let packet = try readPubCompPacket(with: fixedHeader)
            return .pubComp(packet: packet)

        case .subAck:
            let packet = try readSubAckPacket(with: fixedHeader)
            return .subAck(packet: packet)

        case .unsubAck:
            let packet = try readUnsubAckPacket(with: fixedHeader)
            return .unsubAck(packet: packet)

        case .pingResp:
            let packet = PingRespPacket(fixedHeader: fixedHeader)
            return .pingResp(packet: packet)

        case .disconnect:
            let packet = try readDisconnectPacket(with: fixedHeader)
            return .disconnect(packet: packet)

        case .auth:
            let packet = try readAuthPacket(with: fixedHeader)
            return .auth(packet: packet)

        default:
            throw MQTTCodingError.malformedPacket
        }
    }

    @discardableResult
    mutating func write(_ controlPacket: ControlPacket) throws -> Int {
        switch controlPacket {
        case let .connect(packet):
            return try write(packet)

        case let .publish(packet):
            return try write(packet)

        case let .pubAck(packet):
            return try write(packet)

        case let .pubRec(packet):
            return try write(packet)

        case let .pubRel(packet):
            return try write(packet)

        case let .pubComp(packet):
            return try write(packet)

        case let .subscribe(packet):
            return try write(packet)

        case let .unsubscribe(packet):
            return try write(packet)

        case let .pingReq(packet: packet):
            return try write(packet.fixedHeader)

        case let .disconnect(packet):
            return try write(packet)

        case let .auth(packet):
            return try write(packet)

        default:
            throw MQTTCodingError.malformedPacket
        }
    }
}
