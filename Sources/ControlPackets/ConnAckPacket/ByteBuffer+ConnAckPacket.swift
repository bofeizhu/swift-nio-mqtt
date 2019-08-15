//
//  ByteBuffer+ConnAckPacket.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 8/14/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

import NIO

extension ByteBuffer {

    mutating func readConnAckPacket(with fixedHeader: FixedHeader) throws -> ConnAckPacket? {
        return nil
    }
}
