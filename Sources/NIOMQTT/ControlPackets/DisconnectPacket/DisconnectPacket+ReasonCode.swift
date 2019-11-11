//
//  DisconnectPacket+ReasonCode.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 7/22/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

extension DisconnectPacket {
    /// DISCONNECT Reason Code
    enum ReasonCode: ReasonCodeValue {
        /// Normal disconnection
        ///
        /// Close the connection normally. Do not send the Will Message.
        case normalDisconnection = 0

        /// Disconnect with Will Message
        ///
        /// The Client wishes to disconnect but requires that the Server also publishes its Will Message.
        case disconnectWithWillMessage = 4

        /// Unspecified Error
        ///
        /// The Connection is closed but the sender either does not wish to reveal the reason,
        /// or none of the other Reason Codes apply.
        case unspecifiedError = 128

        /// Malformed Packet
        ///
        /// The received packet does not conform to this specification.
        case malformedPacket = 129

        /// Protocol Error
        ///
        /// An unexpected or out of order packet was received.
        case protocolError = 130

        /// Implementation Specific Error
        ///
        /// The packet received is valid but cannot be processed by this implementation.
        case implementationSpecificError = 131

        /// Not Authorized
        ///
        /// The request is not authorized.
        case notAuthorized = 135

        /// Server Busy
        ///
        /// The Server is busy and cannot continue processing requests from this Client.
        case serverBusy = 137

        /// Server Shutting Down
        ///
        /// The Server is shutting down.
        case serverShuttingDown = 139

        /// Keep Alive Timeout
        ///
        /// The Connection is closed because no packet has been received for 1.5 times the Keepalive time.
        case badAuthenticationMethod = 141

        /// Session Taken Over
        ///
        /// Another Connection using the same ClientID has connected causing this Connection to be closed.
        case sessionTakenOver = 142

        /// Topic Filter Invalid
        ///
        /// The Topic Filter is correctly formed, but is not accepted by this Sever.
        case topicFilterInvalid = 143

        /// Topic Name Invalid
        ///
        /// The Will Topic Name is not malformed, but is not accepted by this Server.
        case topicNameInvalid = 144

        /// Receive Maximum Exceeded
        ///
        /// The Client or Server has received more than Receive Maximum publication
        /// for which it has not sent PUBACK or PUBCOMP.
        case receiveMaximumExceeded = 147

        /// Topic Alias Invalid
        ///
        /// The Client or Server has received a PUBLISH packet containing a Topic Alias
        /// which is greater than the Maximum Topic Alias it sent in the CONNECT or CONNACK packet.
        case topicAliasInvalid = 148

        /// Packet Too Large
        ///
        /// The packet size is greater than Maximum Packet Size for this Client or Server.
        case packetTooLarge = 149

        /// Message Rate Too High
        ///
        /// The received data rate is too high.
        case messageRateTooHigh = 150

        /// Quota Exceeded
        ///
        /// An implementation or administrative imposed limit has been exceeded.
        case quotaExceeded = 151

        /// Administrative Action
        ///
        /// The Connection is closed due to an administrative action.
        case administrativeAction = 152

        /// Payload Format Invalid
        ///
        /// The payload format does not match the one specified by the Payload Format Indicator.
        case payloadFormatInvalid = 153

        /// Retain Not Supported
        ///
        /// The Server has does not support retained messages.
        case retainNotSupported = 154

        /// QoS Not Supported
        ///
        /// The Client specified a QoS greater than the QoS specified in a Maximum QoS in the CONNACK.
        case qosNotSupported = 155

        /// Use Another Server
        ///
        /// The Client should temporarily use another server.
        case useAnotherServer = 156

        /// Server Moved
        ///
        /// The Server is moved and the Client should permanently change its server location.
        case serverMoved = 157

        /// Shared Subscriptions Not Supported
        ///
        /// The Server does not support Shared Subscriptions.
        case sharedSubscriptionsNotSupported = 158

        /// Connection Rate Exceeded
        ///
        /// This connection is closed because the connection rate is too high.
        case connectionRateExceeded = 159

        /// Maximum Connect Time
        ///
        /// The maximum connection time authorized for this connection has been exceeded.
        case maximumConnectTime = 160

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
