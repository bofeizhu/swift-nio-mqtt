//
//  PublishFixedHeaderType.swift
//  NIOMQTT
//
//  Created by Elian Imlay-Maire on 9/16/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

/// FixedHeader with a Publish Control Packet Types
struct PublishFixedHeaderType {
    let dup: Bool
    let qos: QoS
    let retain: Bool

    init?(reserve: UInt8) {
        guard let qos = QoS(rawValue: (reserve >> 1) & 0b11) else { return nil }
        let dup = ((reserve >> 3) & 1) == 1
        let retain = (reserve & 1) == 1
        self.init(dup: dup, qos: qos, retain: retain)
    }

    init(dup: Bool, qos: QoS, retain: Bool) {
        self.dup = dup
        self.qos = qos
        self.retain = retain
    }
}

extension PublishFixedHeaderType: FixedHeaderType {
    var controlPacketTypeRawValue: UInt8 {
        return UInt8(3)
    }

    var reserveRawValue: UInt8 {
        let bit0: UInt8 = retain ? 1 : 0
        let bit12 = qos.rawValue
        let bit3: UInt8 = dup ? 1 : 0
        return (bit3 << 3) | (bit12 << 1) | bit0
    }
}
