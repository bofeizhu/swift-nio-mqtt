//
//  KeepAliveHandler.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 9/4/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

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
    private var pingRequestTask: (deadline: NIODeadline, scheduled: Scheduled<Void>)?
    private var pingResponseTimeoutTask: Scheduled<Void>?

    // TODO: Make timeout configurable
    private let pingResponseTimeout = TimeAmount.seconds(10)

    init(keepAlive: UInt16) {

        self.keepAlive = .seconds(TimeAmount.Value(keepAlive))

        // TODO: Add throttling customization
        throttleInterval = .seconds(TimeAmount.Value(keepAlive / 2))
    }

    func handlerAdded(context: ChannelHandlerContext) {
        pingRequestTask = schedulePingReq(context: context)
    }

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {

        let packet = unwrapInboundIn(data)

        switch packet {
        case .pingResp:

            guard let task = pingResponseTimeoutTask else {
                break
            }

            // Received PINGRESP, cancel timeout task
            task.cancel()

        default:

            // TODO: Unhandled packet
            break
        }
    }

    func write(context: ChannelHandlerContext, data: NIOAny, promise: EventLoopPromise<Void>?) {

        // New packet is being sent; cancel PINGREQ and reschedule
        if let (deadline, scheduled) = pingRequestTask,
           deadline + throttleInterval < NIODeadline.now() {

            scheduled.cancel()
            pingRequestTask = schedulePingReq(context: context)
        }

        context.write(data, promise: promise)
    }

    private func schedulePingReq(context: ChannelHandlerContext) -> (NIODeadline, Scheduled<Void>) {

        let deadline: NIODeadline = .now() + keepAlive

        let scheduled = context.channel.eventLoop.scheduleTask(deadline: deadline) { [weak self] in

            guard let strongSelf = self else {
                return
            }

            let promise: EventLoopPromise<Void> = context.channel.eventLoop.makePromise()

            // TODO: Handle failure state
            promise.futureResult.whenSuccess { _ in

                // Schedule PINGRESP timeout task
                strongSelf.pingResponseTimeoutTask = strongSelf.schedulePingRespTimeout(context: context)

                // Schedule next PINGREQ task
                strongSelf.pingRequestTask = strongSelf.schedulePingReq(context: context)
            }

            let packet = PingReqPacket()
            let data = strongSelf.wrapOutboundOut(.pingReq(packet: packet))
            context.writeAndFlush(data, promise: promise)
        }

        return (deadline, scheduled)
    }

    private func schedulePingRespTimeout(context: ChannelHandlerContext) -> Scheduled<Void> {
        return context.channel.eventLoop.scheduleTask(in: pingResponseTimeout) { [weak self] in
            guard let _ = self else {
                return
            }

            // TODO: Close connection
            print("Canceled")
        }
    }
}
