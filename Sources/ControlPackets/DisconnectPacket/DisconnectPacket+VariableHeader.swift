//
//  DisconnectPacket+VariableHeader.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 8/20/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

extension DisconnectPacket: VariableHeaderPacket {

    struct VariableHeader: HasProperties, MQTTByteRepresentable {

        /// Reason Code
        let reasonCode: ReasonCode

        /// Properties
        let properties: PropertyCollection

        var mqttByteCount: Int {
            ReasonCodeValue.byteCount + properties.mqttByteCount
        }
    }
}
