//
//  Session.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 9/10/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

import NIOConcurrencyHelpers

final class Session {

    var packetIdentifier = Atomic<UInt16>(value: 0)

    func nextPacketIdentifier() -> UInt16 {
        return packetIdentifier.add(1)
    }
}
