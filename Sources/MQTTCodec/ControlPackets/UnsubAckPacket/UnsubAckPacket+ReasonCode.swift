//
//  UnsubAckPacket+ReasonCode.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 8/19/19.
//  Copyright © 2019 Bofei Zhu. All rights reserved.
//

extension UnsubAckPacket {

    /// SUBACK Reason Code
    enum ReasonCode: ReasonCodeValue {

        /// Success
        ///
        /// The subscription is deleted.
        case success = 0

        /// No Subscription Existed
        ///
        /// No matching Topic Filter is being used by the Client.
        case noSubscriptionExisted = 17

        /// Unspecified error
        ///
        /// The unsubscribe could not be completed and the Server either does not wish to reveal the reason
        /// or none of the other Reason Codes apply.
        case unspecifiedError = 128

        /// Implementation Specific Error
        ///
        /// The UNSUBSCRIBE is valid but the Server does not accept it.
        case implementationSpecificError = 131

        /// Not Authorized
        ///
        /// The Client is not authorized to unsubscribe.
        case notAuthorized = 135

        /// Topic Filter Invalid
        ///
        /// The Topic Filter is correctly formed but is not allowed for this Client.
        case topicFilterInvalid = 143

        /// Packet Identifier In Use
        ///
        /// The specified Packet Identifier is already in use.
        case packetIdentifierInUse = 145
    }
}
