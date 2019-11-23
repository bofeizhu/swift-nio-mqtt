//
//  SubAckPacket+Payload.swift
//  MQTTCodec
//
//  Created by Bofei Zhu on 8/19/19.
//  Copyright © 2019 Bofei Zhu. All rights reserved.
//

extension SubAckPacket: PayloadPacket {

    /// SUBACK Payload
    struct Payload: MQTTByteRepresentable {

        /// Reason Codes
        ///
        /// The Payload contains a list of Reason Codes.
        /// Each Reason Code corresponds to a Topic Filter in the SUBSCRIBE packet being acknowledged.
        /// - Important: The order of Reason Codes in the SUBACK packet **MUST** match
        ///     the order of Topic Filters in the SUBSCRIBE packet
        let reasonCodes: [ReasonCode]

        var mqttByteCount: Int {
            reasonCodes.count
        }
    }
}
