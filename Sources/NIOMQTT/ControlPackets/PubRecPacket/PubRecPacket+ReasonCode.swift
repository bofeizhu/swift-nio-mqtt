//
//  PubRecPacket+ReasonCode.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 7/28/19.
//  Copyright © 2019 Bofei Zhu. All rights reserved.
//

extension PubRecPacket {

    /// PUBREC Reason Code
    enum ReasonCode: ReasonCodeValue {

        /// Success
        ///
        /// The message is accepted. Publication of the QoS 2 message proceeds.
        case success = 0

        /// No Matching Subscribers
        ///
        /// The message is accepted but there are no subscribers.
        /// This is sent only by the Server.
        /// If the Server knows that there are no matching subscribers,
        /// it MAY use this Reason Code instead of 0x00 (Success).
        case noMatchingSubscribers = 16

        /// Unspecified Error
        ///
        /// The receiver does not accept the publish but
        /// either does not want to reveal the reason,
        /// or it does not match one of the other values.
        case unspecifiedError = 128

        /// Implementation Specific Error
        ///
        /// The PUBLISH is valid but the receiver is not willing to accept it.
        case implementationSpecificError = 131

        /// Not Authorized
        ///
        /// The PUBLISH is not authorized.
        case notAuthorized = 135

        /// Topic Name Invalid
        ///
        /// The Topic Name is not malformed, but is not accepted by this Client or Server.
        case topicNameInvalid = 144

        /// Packet Identifier In Use
        ///
        /// The Packet Identifier is already in use.
        /// This might indicate a mismatch in the Session State between the Client and Server.
        case packetIdentifierInUse = 145

        /// Quota Exceeded
        ///
        /// An implementation or administrative imposed limit has been exceeded.
        case quotaExceeded = 151

        /// Payload Format Invalid
        ///
        /// The payload format does not match the specified Payload Format Indicator.
        case payloadFormatInvalid = 153
    }
}
