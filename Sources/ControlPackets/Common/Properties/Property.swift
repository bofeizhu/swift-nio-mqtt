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
    case requestProblemInformation(Bool)

    /// Will Delay Interval
    case willDelayInterval(UInt32)

    /// Request Response Information
    case requestResponseInformation(Bool)

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
    case maximumQoS(QoS)

    /// Retain Available
    case retainAvailable(Bool)

    /// User Property
    case userProperty(StringPair)

    /// Maximum Packet Size
    case maximumPacketSize(UInt32)

    /// Wildcard Subscription Available
    case wildcardSubscriptionAvailable(Bool)

    /// Subscription Identifier Available
    case subscriptionIdentifierAvailable(Bool)

    /// Shared Subscription Available
    case sharedSubscriptionAvailable(Bool)
}

extension Property {

    /// Byte count
    ///
    /// - Important: Byte count includes the identifier byte.
    var byteCount: Int {
        var count = 1

        switch self {
        case .payloadFormatIndicator:
            count += 1

        case .messageExpiryInterval:
            count += 4

        case let .contentType(type):
            count += type.mqttByteCount

        case let .responseTopic(topic):
            count += topic.mqttByteCount

        case let .correlationData(data):
            count += data.mqttByteCount

        case let .subscriptionIdentifier(identifier):
            count += identifier.bytes.count

        case .sessionExpiryInterval:
            count += 4

        case let .assignedClientIdentifier(identifier):
            count += identifier.mqttByteCount

        case .serverKeepAlive:
            count += 2

        case let .authenticationMethod(method):
            count += method.mqttByteCount

        case let .authenticationData(data):
            count += data.mqttByteCount

        case .requestProblemInformation:
            count += 1

        case .willDelayInterval:
            count += 4

        case .requestResponseInformation:
            count += 1

        case let .responseInformation(information):
            count += information.mqttByteCount

        case let .serverReference(reference):
            count += reference.mqttByteCount

        case let .reasonString(string):
            count += string.mqttByteCount

        case .receiveMaximum:
            count += 2

        case .topicAliasMaximum:
            count += 2

        case .topicAlias:
            count += 2

        case .maximumQoS:
            count += 1

        case .retainAvailable:
            count += 1

        case let .userProperty(property):
            count += property.mqttByteCount

        case .maximumPacketSize:
            count += 4

        case .wildcardSubscriptionAvailable:
            count += 1

        case .subscriptionIdentifierAvailable:
            count += 1

        case .sharedSubscriptionAvailable:
            count += 1
        }
        return count
    }
}
