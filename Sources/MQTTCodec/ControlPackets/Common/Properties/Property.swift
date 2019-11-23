//
//  Property.swift
//  MQTTCodec
//
//  Created by Bofei Zhu on 6/18/19.
//  Copyright © 2019 Bofei Zhu. All rights reserved.
//

import struct Foundation.Data

/// Control Packet Property
///
/// The last field in the Variable Header of the CONNECT, CONNACK, PUBLISH, PUBACK, PUBREC,
/// PUBREL, PUBCOMP, SUBSCRIBE, SUBACK, UNSUBSCRIBE, UNSUBACK, DISCONNECT, and AUTH packet is a set of Properties.
/// In the CONNECT packet there is also an optional set of Properties in the Will Properties field with the Payload.
///
/// The set of Properties is composed of a Property Length followed by the Properties.
public enum Property {
    /// Payload Format Indicator
    ///
    /// `false` Indicates that the Payload is unspecified bytes,
    /// which is equivalent to not sending a Payload Format Indicator.
    /// `true`  Indicates that the Payload is UTF-8 Encoded Character Data.
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

    var propertyIdentifier: PropertyIdentifier {
        switch self {
        case .payloadFormatIndicator:
            return .payloadFormatIndicator

        case .messageExpiryInterval:
            return .messageExpiryInterval

        case .contentType:
            return .contentType

        case .responseTopic:
            return .responseTopic

        case .correlationData:
            return .correlationData

        case .subscriptionIdentifier:
            return .subscriptionIdentifier

        case .sessionExpiryInterval:
            return .sessionExpiryInterval

        case .assignedClientIdentifier:
            return .assignedClientIdentifier
        case .serverKeepAlive:
            return .serverKeepAlive

        case .authenticationMethod:
            return .authenticationMethod

        case .authenticationData:
            return .authenticationData

        case .requestProblemInformation:
            return .requestProblemInformation

        case .willDelayInterval:
            return .willDelayInterval

        case .requestResponseInformation:
            return .requestResponseInformation

        case .responseInformation:
            return .responseInformation

        case .serverReference:
            return .serverReference

        case .reasonString:
            return .reasonString

        case .receiveMaximum:
            return .receiveMaximum

        case .topicAliasMaximum:
            return .topicAliasMaximum

        case .topicAlias:
            return .topicAlias

        case .maximumQoS:
            return .maximumQoS

        case .retainAvailable:
            return .retainAvailable

        case .userProperty:
            return .userProperty

        case .maximumPacketSize:
            return .maximumPacketSize

        case .wildcardSubscriptionAvailable:
            return .wildcardSubscriptionAvailable

        case .subscriptionIdentifierAvailable:
            return .subscriptionIdentifierAvailable

        case .sharedSubscriptionAvailable:
            return .sharedSubscriptionAvailable
        }
    }
}

// MARK: - Equatable

extension Property: Equatable {}

// MARK: - MQTTByteRepresentable

extension Property: MQTTByteRepresentable {

    /// Byte count
    ///
    /// - Important: Byte count includes the identifier byte.
    var mqttByteCount: Int {
        var count = 1

        switch self {
        case .payloadFormatIndicator:
            count += UInt8.byteCount

        case .messageExpiryInterval:
            count += UInt32.byteCount

        case let .contentType(type):
            count += type.mqttByteCount

        case let .responseTopic(topic):
            count += topic.mqttByteCount

        case let .correlationData(data):
            count += data.mqttByteCount

        case let .subscriptionIdentifier(identifier):
            count += identifier.mqttByteCount

        case .sessionExpiryInterval:
            count += UInt32.byteCount

        case let .assignedClientIdentifier(identifier):
            count += identifier.mqttByteCount

        case .serverKeepAlive:
            count += UInt16.byteCount

        case let .authenticationMethod(method):
            count += method.mqttByteCount

        case let .authenticationData(data):
            count += data.mqttByteCount

        case .requestProblemInformation:
            count += UInt8.byteCount

        case .willDelayInterval:
            count += UInt32.byteCount

        case .requestResponseInformation:
            count += UInt8.byteCount

        case let .responseInformation(information):
            count += information.mqttByteCount

        case let .serverReference(reference):
            count += reference.mqttByteCount

        case let .reasonString(string):
            count += string.mqttByteCount

        case .receiveMaximum:
            count += UInt16.byteCount

        case .topicAliasMaximum:
            count += UInt16.byteCount

        case .topicAlias:
            count += UInt16.byteCount

        case .maximumQoS:
            count += UInt8.byteCount

        case .retainAvailable:
            count += UInt8.byteCount

        case let .userProperty(property):
            count += property.mqttByteCount

        case .maximumPacketSize:
            count += UInt32.byteCount

        case .wildcardSubscriptionAvailable:
            count += UInt8.byteCount

        case .subscriptionIdentifierAvailable:
            count += UInt8.byteCount

        case .sharedSubscriptionAvailable:
            count += UInt8.byteCount
        }
        return count
    }
}
