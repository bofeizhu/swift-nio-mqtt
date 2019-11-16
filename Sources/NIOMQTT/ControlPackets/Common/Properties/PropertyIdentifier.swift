//
//  PropertyIdentifier.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 7/21/19.
//  Copyright © 2019 Bofei Zhu. All rights reserved.
//

import NIO

/// A Property consists of an Identifier which defines its usage and data type, followed by a value.
/// The Identifier is encoded as a Variable Byte Integer.
///
/// - Important: Although the Property Identifier is defined as a Variable Byte Integer,
///     in this version of the specification all of the Property Identifiers are one byte long.
///     So we are treating them as `UInt8`.
enum PropertyIdentifier: UInt8 {
    /// Payload Format Indicator
    case payloadFormatIndicator = 1

    /// Message Expiry Interval
    case messageExpiryInterval = 2

    /// Content Type
    case contentType = 3

    /// Response Topic
    case responseTopic = 8

    /// Correlation Data
    case correlationData = 9

    /// Subscription Identifier
    case subscriptionIdentifier = 11

    /// Session Expiry Interval
    case sessionExpiryInterval = 17

    /// Assigned Client Identifier
    case assignedClientIdentifier = 18

    /// Server Keep Alive
    case serverKeepAlive = 19

    /// Authentication Method
    case authenticationMethod = 21

    /// Authentication Data
    case authenticationData = 22

    /// Request Problem Information
    case requestProblemInformation = 23

    /// Will Delay Interval
    case willDelayInterval = 24

    /// Request Response Information
    case requestResponseInformation = 25

    /// Response Information
    case responseInformation = 26

    /// Server Reference
    case serverReference = 28

    /// Reason String
    case reasonString = 31

    /// Receive Maximum
    case receiveMaximum = 33

    /// Topic Alias Maximum
    case topicAliasMaximum = 34

    /// Topic Alias
    case topicAlias = 35

    /// Maximum QoS
    case maximumQoS = 36

    /// Retain Available
    case retainAvailable = 37

    /// User Property
    case userProperty = 38

    /// Maximum Packet Size
    case maximumPacketSize = 39

    /// Wildcard Subscription Available
    case wildcardSubscriptionAvailable = 40

    /// Subscription Identifier Available
    case subscriptionIdentifierAvailable = 41

    /// Shared Subscription Available
    case sharedSubscriptionAvailable = 42
}

extension ByteBuffer {

    @discardableResult
    mutating func write(_ identifier: PropertyIdentifier) -> Int {
        return writeByte(identifier.rawValue)
    }
}
