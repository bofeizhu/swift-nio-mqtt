//
//  LoggingHandler.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 9/1/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

import NIO

final class LoggingHandler: ChannelDuplexHandler {
    typealias InboundIn = ControlPacket
    typealias InboundOut = ControlPacket
    typealias OutboundIn = ControlPacket
    typealias OutboundOut = ControlPacket

    init() {}

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let packet = self.unwrapInboundIn(data)
        print(String(reflecting: packet))
        context.fireChannelRead(data)
    }

    func write(context: ChannelHandlerContext, data: NIOAny, promise: EventLoopPromise<Void>?) {
        let packet = self.unwrapOutboundIn(data)
        print(String(reflecting: packet))
        context.write(data, promise: promise)
    }
}
