//
//  PropertyIdentifier.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 7/21/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

/// A Property consists of an Identifier which defines its usage and data type, followed by a value.
/// The Identifier is encoded as a Variable Byte Integer.
///
/// - Important: Although the Property Identifier is defined as a Variable Byte Integer,
///     in this version of the specification all of the Property Identifiers are one byte long.
///     So we are treating them as `UInt8`.
enum PropertyIdentifier: UInt8 {

    /// Payload Format Indicator
    case payloadFormatIndicator = 0x01

    /// Message Expiry Interval
    case messageExpiryInterval = 0x02

    /// Content Type
    case contentType = 0x03

    /// Response Topic
    case responseTopic = 0x08

    /// Correlation Data
    case correlationData = 0x09

    /// Subscription Identifier
    case subscriptionIdentifier = 0x0B

    /// Session Expiry Interval
    case sessionExpiryInterval = 0x11

    /// Assigned Client Identifier
    case assignedClientIdentifier = 0x12

    /// Server Keep Alive
    case serverKeepAlive = 0x13

    /// Authentication Method
    case authenticationMethod = 0x15

    /// Authentication Data
    case authenticationData = 0x16

    /// Request Problem Information
    case requestProblemInformation = 0x17

    /// Will Delay Interval
    case willDelayInterval = 0x18

    /// Request Response Information
    case requestResponseInformation = 0x19

    /// Response Information
    case responseInformation = 0x1A

    /// Server Reference
    case serverReference = 0x1C

    /// Reason String
    case reasonString = 0x1F

    /// Receive Maximum
    case receiveMaximum = 0x21

    /// Topic Alias Maximum
    case topicAliasMaximum = 0x22

    /// Topic Alias
    case topicAlias = 0x23

    /// Maximum QoS
    case maximumQoS = 0x24

    /// Retain Available
    case retainAvailable = 0x25

    /// User Property
    case userProperty = 0x26

    /// Maximum Packet Size
    case maximumPacketSize = 0x27

    /// Wildcard Subscription Available
    case wildcardSubscriptionAvailable = 0x28

    /// Subscription Identifier Available
    case subscriptionIdentifierAvailable = 0x29

    /// Shared Subscription Available
    case sharedSubscriptionAvailable = 0x2A
}
