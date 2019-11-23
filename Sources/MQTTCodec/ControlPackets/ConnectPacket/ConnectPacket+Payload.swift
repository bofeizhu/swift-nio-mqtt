//
//  ConnectPacket+Payload.swift
//  MQTTCodec
//
//  Created by Bofei Zhu on 7/21/19.
//  Copyright © 2019 Bofei Zhu. All rights reserved.
//

import struct Foundation.Data

extension ConnectPacket: PayloadPacket {
    /// CONNECT packet Payload
    public struct Payload: MQTTByteRepresentable {

        /// Client Identifier (ClientID)
        public let clientId: String

        /// Will Message
        public let willMessage: WillMessage?

        /// Username
        public let username: String?

        /// Password
        public let password: Data?

        var mqttByteCount: Int {

            var count = clientId.mqttByteCount
            count += willMessage?.mqttByteCount ?? 0
            count += username?.mqttByteCount ?? 0
            count += password?.mqttByteCount ?? 0

            return count
        }
    }

    /// Will Message in CONNECT Packet's payload
    ///
    /// The Will Message consists of the Will Properties, Will Topic,
    /// and Will Payload fields in the CONNECT Payload.
    /// The Will Message MUST be published after the Network Connection is subsequently closed
    /// and either the Will Delay Interval has elapsed or the Session ends, unless the Will Message
    /// has been deleted by the Server on receipt of a DISCONNECT packet
    /// with Reason Code 0x00 (Normal disconnection) or a new Network Connection for
    /// the ClientID is opened before the Will Delay Interval has elapsed
    public struct WillMessage: MQTTByteRepresentable {

        /// Properties
        let properties: PropertyCollection

        /// Topic
        let topic: String

        /// Payload
        let payload: Data

        var mqttByteCount: Int {
            properties.mqttByteCount + topic.mqttByteCount + payload.mqttByteCount
        }
    }
}
