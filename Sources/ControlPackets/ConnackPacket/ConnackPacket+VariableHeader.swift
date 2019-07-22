//
//  ConnackPacket+VariableHeader.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 7/21/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

extension ConnackPacket: VariableHeaderPacket {

    /// The Variable Header for CONNACK Packet
    struct VariableHeader: HasProperties {

        // MARK: Connect Acknowledge Flags

        /// Connect Acknowledge Flags
        ///
        /// Byte 1 is the "Connect Acknowledge Flags". Bits 7-1 are reserved and MUST be set to 0
        /// Bit 0 is the Session Present Flag.
        let connectAcknowledgeFlags: UInt8

        /// Session Present
        ///
        /// Position: bit 0 of the Connect Acknowledge Flags.
        var sessionPresent: Bool {
            return (connectAcknowledgeFlags & 1) == 1
        }

        // MARK: Connect Reason Code

        /// Connect Reason Code
        let connectReasonCode: ConnectReasonCode

        // MARK: Properties

        /// Properties
        let properties: [Property]
    }

    /// Connect Reason Code
    enum ConnectReasonCode: UInt8 {

        /// Success
        ///
        /// The Connection is accepted.
        case success = 0x00

        /// Unspecified Error
        ///
        /// The Server does not wish to reveal the reason for the failure,
        /// or none of the other Reason Codes apply.
        case unspecifiedError = 0x80

        /// Malformed Packet
        ///
        /// Data within the CONNECT packet could not be correctly parsed.
        case malformedPacket = 0x81

        /// Protocol Error
        ///
        /// Data in the CONNECT packet does not conform to this specification.
        case protocolError = 0x82

        /// Implementation Specific Error
        ///
        /// The CONNECT is valid but is not accepted by this Server.
        case implementationSpecificError = 0x83

        /// Unsupported Protocol Version
        ///
        /// The Server does not support the version of the MQTT protocol requested by the Client.
        case unsupportedProtocolVersion = 0x84

        /// Client Identifier Not Valid
        ///
        /// The Client Identifier is a valid string but is not allowed by the Server.
        case clientIdentifierNotValid = 0x85

        /// Bad User Name or Password
        ///
        /// The Server does not accept the User Name or Password specified by the Client
        case badUserNameOrPassword = 0x86

        /// Not Authorized
        ///
        /// The Client is not authorized to connect.
        case notAuthorized = 0x87

        /// Server Unavailable
        ///
        /// The MQTT Server is not available.
        case serverUnavailable = 0x88

        /// Server Busy
        ///
        /// The Server is busy. Try again later.
        case serverBusy = 0x89

        /// Banned
        ///
        /// This Client has been banned by administrative action.
        /// Contact the server administrator.
        case banned = 0x8A

        /// Bad Authentication Method
        ///
        /// The authentication method is not supported
        /// or does not match the authentication method currently in use.
        case badAuthenticationMethod = 0x8C

        /// Topic Name Invalid
        ///
        /// The Will Topic Name is not malformed, but is not accepted by this Server.
        case topicNameInvalid = 0x90

        /// Packet Too Large
        ///
        /// The CONNECT packet exceeded the maximum permissible size.
        case packetTooLarge = 0x95

        /// Quota Exceeded
        ///
        /// An implementation or administrative imposed limit has been exceeded.
        case quotaExceeded = 0x97

        /// Payload Format Invalid
        ///
        /// The Will Payload does not match the specified Payload Format Indicator.
        case payloadFormatInvalid = 0x99

        /// Retain Not Supported
        ///
        /// The Server does not support retained messages, and Will Retain was set to 1.
        case retainNotSupported = 0x9A

        /// QoS Not Supported
        ///
        /// The Server does not support the QoS set in Will QoS.
        case qosNotSupported = 0x9B

        /// Use Another Server
        ///
        /// The Client should temporarily use another server.
        case useAnotherServer = 0x9C

        /// Server Moved
        ///
        /// The Client should permanently use another server.
        case serverMoved = 0x9D

        /// Connection Rate Exceeded
        ///
        /// The connection rate limit has been exceeded.
        case connectionRateExceeded = 0x9F
    }
}
