//
//  PubAckPacket.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 7/22/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

///
struct PubAckPacket: ControlPacket {

    /// Reserved fixed header flags for PUBACK packet
    static let flags: FixedHeaderFlags = 0

    /// Fixed Header
    var fixedHeader: FixedHeader

}
