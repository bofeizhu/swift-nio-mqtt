//
//  AuthPacket+ReasonCode.swift
//  MQTTCodec
//
//  Created by Bofei Zhu on 8/20/19.
//  Copyright © 2019 Bofei Zhu. All rights reserved.
//

extension AuthPacket {
    /// Auth Packet Reason Code
    enum ReasonCode: ReasonCodeValue {
        /// Success
        ///
        /// Authentication is successful
        case success = 0

        /// Continue Authentication
        ///
        /// Continue the authentication with another step
        case continueAuthentication = 24

        /// Re-authenticate
        ///
        /// The subscription is accepted and any received QoS will be sent to this subscription.
        case reauthenticate = 25
    }
}
