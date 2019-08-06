//
//  SubscribePacket+Payload.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 7/21/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

import struct Foundation.Data

extension SubscribePacket: PayloadPacket {

    /// SUBSCRIBE Packet Payload
    struct Payload {

    }

    /// Topic Filter
    ///
    /// Topic Filters indicating the Topics to which the Client wants to subscribe.
    /// The Topic Filters MUST be a UTF-8 Encoded String.
    /// Each Topic Filter is followed by a Subscription Options byte.
    struct TopicFilter {

        /// Topic
        let topic: String

        /// Options
        let options: Options
    }

    struct Options {}
}
