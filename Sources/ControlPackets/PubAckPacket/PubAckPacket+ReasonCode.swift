//
//  PubAckPacket+ReasonCode.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 7/22/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

extension PubAckPacket {

    enum ReasonCode: ReasonCodeValue {

        /// Success
        ///
        /// The message is accepted. Publication of the QoS 1 message proceeds.
        case success = 0

        /// No Matching Subscribers
        ///
        /// The message is accepted. Publication of the QoS 1 message proceeds.
        case noMatchingSubscribers
    }
}
