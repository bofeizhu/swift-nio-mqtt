//
//  FixedHeaderType.swift
//  NIOMQTT
//
//  Created by Elian Imlay-Maire on 9/16/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

/// The FixedHeaderType, containing the Control Packet Type Reserved bits
protocol FixedHeaderType {

    /// The first four bits in the FixedHeader contain the MQTT Control Pack type, listed in [MQTT Control Packet Types]
    /// (http://docs.oasis-open.org/mqtt/mqtt/v5.0/csprd01/mqtt-v5.0-csprd01.html#_Toc489530053)
    var controlPacketTypeRawValue: UInt8 { get }

    /// The last four bits in the Fixed Header contain flags specific to each MQTT Control Packet type.
    var reserveRawValue: UInt8 { get }
}

extension FixedHeaderType {
    var byte: UInt8 {
        return (controlPacketTypeRawValue << 4) | reserveRawValue
    }
}
