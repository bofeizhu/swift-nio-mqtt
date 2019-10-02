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

    private var fixedHeader: FixedHeader?

    func decode(context: ChannelHandlerContext, buffer: inout ByteBuffer) throws -> DecodingState {
        // Read fixed header
        if fixedHeader == nil {
            fixedHeader = try buffer.readFixedHeader()
        }

        // Remaining bytes
        guard
            let fixedHeader = fixedHeader,
            buffer.readableBytes >= fixedHeader.remainingLength.value
        else {
            return .needMoreData
        }

        // Read Control Packet
        let controlPacket = try buffer.readControlPacket(with: fixedHeader)
        context.fireChannelRead(wrapInboundOut(controlPacket))

        // Reset fixed header
        self.fixedHeader = nil

        return .continue
    }

    func decodeLast(context: ChannelHandlerContext, buffer: inout ByteBuffer, seenEOF: Bool) throws -> DecodingState {
        // EOF is not semantic in MQTT, so ignore this.
        return .needMoreData
    }

}
