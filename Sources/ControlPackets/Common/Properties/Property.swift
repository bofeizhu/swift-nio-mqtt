//
//  Property.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 6/18/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

import struct Foundation.Data

/// Control Packet Property
///
/// The last field in the Variable Header of the CONNECT, CONNACK, PUBLISH, PUBACK, PUBREC,
/// PUBREL, PUBCOMP, SUBSCRIBE, SUBACK, UNSUBSCRIBE, UNSUBACK, DISCONNECT, and AUTH packet is a set of Properties.
/// In the CONNECT packet there is also an optional set of Properties in the Will Properties field with the Payload.
///
/// The set of Properties is composed of a Property Length followed by the Properties.
enum Property {

    /// Payload Format Indicator
    case payloadFormatIndicator(Bool)

    /// Message Expiry Interval
    case messageExpiryInterval(UInt32)

    /// Content Type
    case contentType(String)

    /// Response Topic
    case responseTopic(String)

    /// Correlation Data
    case correlationData(Data)

    /// Subscription Identifier
    case subscriptionIdentifier(VInt)

    /// Session Expiry Interval
    case sessionExpiryInterval(UInt32)

    /// Assigned Client Identifier
    case assignedClientIdentifier(String)

    /// Server Keep Alive
    case serverKeepAlive(UInt16)

    /// Authentication Method
    case authenticationMethod(String)

    /// Authentication Data
    case authenticationData(Data)

    /// Request Problem Information
    case requestProblemInformation(UInt8)

    /// Will Delay Interval
    case willDelayInterval(UInt32)

    /// Request Response Information
    case requestResponseInformation(UInt8)

    /// Response Information
    case responseInformation(String)

    /// Server Reference
    case serverReference(String)

    /// Reason String
    case reasonString(String)

    /// Receive Maximum
    case receiveMaximum(UInt16)

    /// Topic Alias Maximum
    case topicAliasMaximum(UInt16)

    /// Topic Alias
    case topicAlias(UInt16)

    /// Maximum QoS
    case maximumQoS(UInt8)

    /// Retain Available
    case retainAvailable(UInt8)

    /// User Property
    case userProperty(StringPair)

    /// Maximum Packet Size
    case maximumPacketSize(UInt32)

    /// Wildcard Subscription Available
    case wildcardSubscriptionAvailable(UInt8)

    /// Subscription Identifier Available
    case subscriptionIdentifierAvailable(UInt8)

    /// Shared Subscription Available
    case sharedSubscriptionAvailable(UInt8)
}
