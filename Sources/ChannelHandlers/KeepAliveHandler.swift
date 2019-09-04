//
//  KeepAliveHandler.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 9/4/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

import Foundation
import NIO

/// Keep Alive Handler
///
/// - Note: We throttle rescheduling PINGREQ if the last schedule is less than half the keep alive interval away.
final class KeepAliveHandler: ChannelDuplexHandler {
    typealias InboundIn = ControlPacket
    typealias InboundOut = ControlPacket
    typealias OutboundIn = ControlPacket
    typealias OutboundOut = ControlPacket

    private let keepAlive: TimeAmount
    private let throttleInterval: TimeAmount
    private var scheduledPingReq: (deadline: NIODeadline, scheduled: Scheduled<Void>)?

    static let pingResponseTimeout = TimeAmount.seconds(5)

    init(keepAlive: UInt16) {

        self.keepAlive = .seconds(TimeAmount.Value(keepAlive))

        // TODO: add throttling customization
        throttleInterval = .seconds(TimeAmount.Value(keepAlive / 2))
    }

    func handlerAdded(context: ChannelHandlerContext) {
        scheduledPingReq = schedulePingReq(context: context)
    }

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {

    }

    func write(context: ChannelHandlerContext, data: NIOAny, promise: EventLoopPromise<Void>?) {

        // New packet being sent, cancel PINGREQ and reschedule
        if let (deadline, scheduled) = scheduledPingReq,
           deadline + throttleInterval < NIODeadline.now() {

            scheduled.cancel()
            scheduledPingReq = schedulePingReq(context: context)
        }

        context.write(data, promise: promise)
    }

    private func schedulePingReq(
        context: ChannelHandlerContext
    ) -> (NIODeadline, Scheduled<Void>) {

        let deadline: NIODeadline = .now() + keepAlive

        let scheduled = context.channel.eventLoop.scheduleTask(deadline: deadline) { [weak self] in

            guard let strongSelf = self else {
                return
            }

            let promise: EventLoopPromise<Void> = context.channel.eventLoop.makePromise()

            promise.futureResult.whenSuccess { _ in

            }

            let packet = PingReqPacket()
            let data = strongSelf.wrapOutboundOut(.pingReq(packet: packet))
            context.writeAndFlush(data, promise: promise)
        }

        return (deadline, scheduled)
    }
}
