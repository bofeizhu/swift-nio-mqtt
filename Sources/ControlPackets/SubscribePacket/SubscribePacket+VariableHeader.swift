//
//  SubscribePacket+VariableHeader.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 7/28/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

extension SubscribePacket: VariableHeaderPacket {

    /// SUBSCRIBE Variable Header
    struct VariableHeader: HasProperties {

        /// Packet Identifier
        let packetIdentifier: UInt16

        /// Properties
        let properties: [Property]
    }
}
