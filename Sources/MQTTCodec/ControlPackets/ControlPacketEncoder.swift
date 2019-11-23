//
//  ControlPacketEncoder.swift
//  MQTTCodec
//
//  Created by Bofei Zhu on 8/29/19.
//  Copyright © 2019 Bofei Zhu. All rights reserved.
//

import NIO

public final class ControlPacketEncoder: MessageToByteEncoder {
    public typealias OutboundIn = ControlPacket

    public init() {}

    public func encode(data: ControlPacket, out: inout ByteBuffer) throws {
        try out.write(data)
    }
}
