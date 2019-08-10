//
//  ControlPacketDecoder.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 8/9/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

import NIO

final class ControlPacketDecoder: ByteToMessageDecoder {
    typealias InboundOut = ControlPacket

    func decode(context: ChannelHandlerContext, buffer: inout ByteBuffer) throws -> DecodingState {

        // Read fix header
        return .continue
    }

    func decodeLast(
        context: ChannelHandlerContext,
        buffer: inout ByteBuffer,
        seenEOF: Bool
    ) throws -> DecodingState {
        return .continue
    }

}
