//
//  SubAckPacket+VariableHeader.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 8/19/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

extension SubAckPacket {

    /// SUBACK Variable Header
    struct VariableHeader: HasProperties {

        /// Properties
        let properties: PropertyCollection
    }
}
