//
//  PubAckPacketBuilder.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 11/13/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

import struct Foundation.Data

final class PubAckPacketBuilder {

    private var packetIdentifier: UInt16

    private var reasonCode: PubAckPacket.ReasonCode = .success

    private var properties = PropertyCollection()

    init(packetIdentifier: UInt16) {
        self.packetIdentifier = packetIdentifier
    }

    // TODO: Add properties

    func reasonCode(_ reasonCode: PubAckPacket.ReasonCode) -> PubAckPacketBuilder {
        self.reasonCode = reasonCode
        return self
    }

    func build() -> PubAckPacket {
        let variableHeader = PubAckPacket.VariableHeader(
            packetIdentifier: packetIdentifier,
            reasonCode: reasonCode,
            properties: properties)

        let fixedHeader = FixedHeader(type: .pubAck, flags: .pubAck, remainingLength: variableHeader.mqttByteCount)

        return PubAckPacket(fixedHeader: fixedHeader, variableHeader: variableHeader)
    }
}
