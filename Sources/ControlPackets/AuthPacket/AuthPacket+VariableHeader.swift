//
//  AuthPacket+VariableHeader.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 8/20/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

extension AuthPacket: VariableHeaderPacket {

    struct VariableHeader: HasProperties {

        /// Reason Code
        let reasonCode: ReasonCode

        /// Properties
        let properties: PropertyCollection
    }
}
