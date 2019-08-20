//
//  UnsubAckPacket+ReasonCode.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 8/19/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

extension UnsubAckPacket {

    /// SUBACK Reason Code
    enum ReasonCode: ReasonCodeValue {

        /// Granted QoS 0
        ///
        /// The subscription is accepted and the maximum QoS sent will be QoS 0.
        /// This might be a lower QoS than was requested.
        case grantedQoS0 = 0

        /// Granted QoS 1
        ///
        /// The subscription is accepted and the maximum QoS sent will be QoS 1.
        /// This might be a lower QoS than was requested.
        case grantedQoS1 = 1

        /// Granted QoS 2
        ///
        /// The subscription is accepted and any received QoS will be sent to this subscription.
        case grantedQoS2 = 2

        /// Unspecified error
        ///
        /// The subscription is not accepted and the Server either does not wish to reveal the reason
        /// or none of the other Reason Codes apply.
        case unspecifiedError = 128

        /// Implementation Specific Error
        ///
        /// The SUBSCRIBE is valid but the Server does not accept it.
        case implementationSpecificError = 131

        /// Not Authorized
        ///
        /// The Client is not authorized to make this subscription.
        case notAuthorized = 135

        /// Topic Filter Invalid
        ///
        /// The Topic Filter is correctly formed but is not allowed for this Client.
        case topicFilterInvalid = 143

        /// Packet Identifier In Use
        ///
        /// The specified Packet Identifier is already in use.
        case packetIdentifierInUse = 145

        /// Quota Exceeded
        ///
        /// An implementation or administrative imposed limit has been exceeded.
        case quotaExceeded = 151

        /// Shared Subscriptions Not Supported
        ///
        /// The Server does not support Shared Subscriptions for this Client.
        case sharedSubscriptionsNotSupported = 158

        /// Subscription Identifiers Not Supported
        ///
        /// The Server does not support Subscription
        case subscriptionIdentifiersNotSupported = 161

        /// Wildcard Subscriptions Not Supported
        ///
        /// The Server does not support Wildcard Subscriptions; the subscription is not accepted.
        case wildcardSubscriptionsNotSupported = 162
    }
}
