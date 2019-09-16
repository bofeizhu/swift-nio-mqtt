//
//  ReservedFixedHeaderType.swift
//  NIOMQTT
//
//  Created by Elian Imlay-Maire on 9/16/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//


/// FixedHeaders with a Control Packet Type that has a derived reserve value.
enum ReservedFixedHeaderType: UInt8 {
    /// Reserved
    case reserved = 0

    /// Connection request
    case connect = 1

    /// Connect acknowledgment
    case connAck = 2

    /// Publish acknowledgment (QoS 1)
    case pubAck = 4

    /// Publish received (QoS 2 delivery part 1)
    case pubRec = 5

    /// Publish release (QoS 2 delivery part 2)
    case pubRel = 6

    /// Publish complete (QoS 2 delivery part 3)
    case pubComp = 7

    /// Subscribe request
    case subscribe = 8

    /// Subscribe acknowledgment
    case subAck = 9

    /// Unsubscribe request
    case unsubscribe = 10

    /// Unsubscribe acknowledgment
    case unsubAck = 11

    /// PING request
    case pingReq = 12

    /// PING response
    case pingResp = 13

    /// Disconnect notification
    case disconnect = 14

    /// Authentication exchange
    case auth = 15
}

extension ReservedFixedHeaderType: Equatable {}

extension ReservedFixedHeaderType: FixedHeaderType {
    var controlPacketTypeRawValue: UInt8 {
        return self.rawValue
    }

    var reserveRawValue: UInt8 {
        switch self {

        case .reserved,
             .connect,
             .connAck,
             .pubAck,
             .pubRec,
             .pubComp,
             .subAck,
             .unsubAck,
             .pingReq,
             .pingResp,
             .disconnect,
             .auth:
            return 0

        case .pubRel, .subscribe, .unsubscribe:
            return 2
        }
    }
}
