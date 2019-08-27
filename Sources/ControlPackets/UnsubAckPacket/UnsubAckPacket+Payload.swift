//
//  UnsubAckPacket+Payload.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 8/19/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

extension UnsubAckPacket: PayloadPacket {

    struct Payload: MQTTByteRepresentable {

        /// Reason Codes
        ///
        /// A list of Reason Codes. Each Reason Code corresponds to a Topic Filter in the UNSUBSCRIBE packet
        /// being acknowledged.
        /// - Important: The order of Reason Codes in the UNSUBACK packet **MUST** match
        ///     the order of Topic Filters in the UNSUBSCRIBE packet
        let reasonCodes: [ReasonCode]

        var mqttByteCount: Int {
            reasonCodes.count
        }
    }
}
