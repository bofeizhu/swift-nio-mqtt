//
//  Session.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 9/10/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

import NIOConcurrencyHelpers

final class Session {

    var packetIdentifier = Atomic<UInt16>(value: 1)

    func nextPacketIdentifier() -> UInt16 {
        if packetIdentifier.compareAndExchange(expected: UInt16.max, desired: 1) {
            return UInt16.max
        }
        return packetIdentifier.add(1)
    }
}
