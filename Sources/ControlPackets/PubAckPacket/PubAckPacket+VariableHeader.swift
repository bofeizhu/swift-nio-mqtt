//
//  PubAckPacket+VariableHeader.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 7/22/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

extension PubAckPacket: VariableHeaderPacket {

    /// PUBACK Variable Header
    struct VariableHeader: HasProperties {

        /// Packet Identifier
        let packetIdentifier: UInt16

        /// PUBACK Reason Code
        let reasonCode: ReasonCode

        /// Properties
        let properties: PropertyCollection
    }
}
