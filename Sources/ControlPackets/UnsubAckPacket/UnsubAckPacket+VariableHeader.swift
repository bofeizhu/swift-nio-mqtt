//
//  UnsubAckPacket+VariableHeader.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 8/19/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

extension UnsubAckPacket: VariableHeaderPacket {

    struct VariableHeader: HasProperties {

        let packetIdentifier: UInt16

        let properties: PropertyCollection
    }
}
