//
//  PubAckPacketBuilder.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 11/13/19.
//  Copyright © 2019 Bofei Zhu. All rights reserved.
//

final class PubAckPacketBuilder {

    private let packetIdentifier: UInt16

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

    /// Build PUBACK packet.
    ///
    /// - Returns: A PUBACK packet.
    func build() -> PubAckPacket {
        let variableHeader = PubAckPacket.VariableHeader(
            packetIdentifier: packetIdentifier,
            reasonCode: reasonCode,
            properties: properties)

        let fixedHeader = FixedHeader(type: .pubAck, flags: .pubAck, remainingLength: variableHeader.mqttByteCount)

        return PubAckPacket(fixedHeader: fixedHeader, variableHeader: variableHeader)
    }
}
