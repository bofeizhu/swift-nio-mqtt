//
//  ConnectPacket+Payload.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 7/21/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

import struct Foundation.Data

extension ConnectPacket: PayloadPacket {

    /// The Payload for the CONNECT Packet
    struct Payload {

        /// The Will Message consists of the Will Properties, Will Topic, and Will Payload fields in the CONNECT Payload.
        /// The Will Message MUST be published after the Network Connection is subsequently closed and
        /// either the Will Delay Interval has elapsed or the Session ends, unless the Will Message
        /// has been deleted by the Server on receipt of a DISCONNECT packet with Reason Code 0x00 (Normal disconnection)
        /// or a new Network Connection for the ClientID is opened before the Will Delay Interval has elapsed
        struct WillMessage {

            /// Properties
            var properties: [Property]

            /// Topic
            var topic: String

            /// Payload
            var payload: Data
        }

        /// Client Identifier (ClientID)
        let clientId: String

        /// Will Message
        let willMessage: WillMessage?

        /// Username
        let username: String?

        /// Password
        let password: String?
    }
}
