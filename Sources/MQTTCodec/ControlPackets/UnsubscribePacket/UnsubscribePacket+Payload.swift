//
//  UnsubscribePacket+Payload.swift
//  MQTTCodec
//
//  Created by Bofei Zhu on 8/19/19.
//  Copyright © 2019 Bofei Zhu. All rights reserved.
//

extension UnsubscribePacket: PayloadPacket {

    /// UNSUBSCRIBE Packet Payload
    public struct Payload: MQTTByteRepresentable {

        /// Topic Filter List
        ///
        /// A list of Topic Filters indicating the Topics to which the Client wants to ubsubscribe from.
        /// - Important: The Payload of an UNSUBSCRIBE packet MUST contain at least one Topic Filter.
        ///     An UNSUBSCRIBE packet with no Payload is a Protocol Error.
        public let topicFilters: [String]

        /// MQTT Byte Count
        ///
        /// - Complexity: O(*n*)
        var mqttByteCount: Int {
            topicFilters.reduce(0) { $0 + $1.mqttByteCount }
        }
    }
}
