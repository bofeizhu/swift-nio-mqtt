//
//  ControlPacketEncoder.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 8/29/19.
//  Copyright © 2019 Bofei Zhu. All rights reserved.
//

import NIO

final class ControlPacketEncoder: MessageToByteEncoder {
    typealias OutboundIn = ControlPacket

    func encode(data: ControlPacket, out: inout ByteBuffer) throws {
        try out.write(data)
    }
}
