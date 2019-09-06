//
//  KeepAliveHandler.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 9/4/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

import NIO

/// Keep Alive Handler
final class KeepAliveHandler: ChannelDuplexHandler {
    typealias InboundIn = ControlPacket
    typealias InboundOut = ControlPacket
    typealias OutboundIn = ControlPacket
    typealias OutboundOut = ControlPacket

    private var pingResponseTimeoutTask: Scheduled<Void>?

    // TODO: Make timeout configurable
    private let pingResponseTimeout = TimeAmount.seconds(5)

    init() {}

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {

        let packet = unwrapInboundIn(data)

        switch packet {

        case .pingResp:
            pingResponseTimeoutTask?.cancel()

        default:
            context.fireChannelRead(data)
        }
    }

    func userInboundEventTriggered(context: ChannelHandlerContext, event: Any) {

        if let idleEvent = event as? IdleStateHandler.IdleStateEvent, idleEvent == .write {
            let writePromise: EventLoopPromise<Void> = context.channel.eventLoop.makePromise()
            writePromise.futureResult.whenComplete { _ in

                // TODO: Handle failure

                self.pingResponseTimeoutTask = self.schedulePingRespTimeout(context: context)
            }

            let packet = PingReqPacket()
            let data = wrapOutboundOut(.pingReq(packet: packet))
            context.writeAndFlush(data, promise: writePromise)
        } else {
            context.fireUserInboundEventTriggered(event)
        }
    }

    private func schedulePingRespTimeout(context: ChannelHandlerContext) -> Scheduled<Void> {

        return context.channel.eventLoop.scheduleTask(in: pingResponseTimeout) {

            // TODO: Close connection
            print("Closed")
        }
    }
}
