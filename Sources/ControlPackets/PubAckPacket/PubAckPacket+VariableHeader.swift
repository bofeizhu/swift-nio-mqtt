//
//  PubAckPacket+VariableHeader.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 7/22/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

extension PubAckPacket: VariableHeaderPacket {

    struct VariableHeader: HasProperties {

        /// Properties
        var properties: [Property]
    }
}
