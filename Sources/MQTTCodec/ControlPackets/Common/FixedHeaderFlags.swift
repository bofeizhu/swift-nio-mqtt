//
//  FixedHeaderFlags.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 8/16/19.
//  Copyright © 2019 Bofei Zhu. All rights reserved.
//

/// The last four bits in the Fixed Header contain flags specific to each MQTT Control Packet type.
public enum FixedHeaderFlags {
    /// Connection request
    case connect

    /// Connect acknowledgment
    case connAck

    /// Publish message
    case publish(dup: Bool, qos: QoS, retain: Bool)

    /// Publish acknowledgment (QoS 1)
    case pubAck

    /// Publish received (QoS 2 delivery part 1)
    case pubRec

    /// Publish release (QoS 2 delivery part 2)
    case pubRel

    /// Publish complete (QoS 2 delivery part 3)
    case pubComp

    /// Subscribe request
    case subscribe

    /// Subscribe acknowledgment
    case subAck

    /// Unsubscribe request
    case unsubscribe

    /// Unsubscribe acknowledgment
    case unsubAck

    /// PING request
    case pingReq

    /// PING response
    case pingResp

    /// Disconnect notification
    case disconnect

    /// Authentication exchange
    case auth

    var value: UInt8 {
        switch self {
        case .connect,
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

        case let .publish(dup, qos, retain):
            let bit0: UInt8 = retain ? 1 : 0
            let bit12 = qos.rawValue
            let bit3: UInt8 = dup ? 1 : 0
            return (bit3 << 3) | (bit12 << 1) | bit0
        }
    }
}

// MARK: - Factory Methods

extension FixedHeaderFlags {

    static func makeFixedHeaderFlags(for type: ControlPacketType, value: UInt8) -> FixedHeaderFlags? {
        guard validateFixedHeaderFlags(type: type, value: value) else {
            return nil
        }

        switch type {
        case .connect:
            return .connect

        case .connAck:
            return .connAck

        case .publish:
            return makePublishFixedHeaderFlags(value: value)

        case .pubAck:
            return .connAck

        case .pubRec:
            return .pubRec

        case .pubRel:
            return .pubRel

        case .pubComp:
            return .pubComp

        case .subscribe:
            return .subscribe

        case .subAck:
            return .subAck

        case .unsubscribe:
            return .unsubscribe

        case .unsubAck:
            return .unsubAck

        case .pingReq:
            return .pingReq

        case .pingResp:
            return .pingResp

        case .disconnect:
            return .disconnect

        case .auth:
            return .auth
        }
    }

    static func makeDefaultFixedHeaderFlags(for type: ControlPacketType) -> FixedHeaderFlags {
        switch type {
        case .connect:
            return .connect

        case .connAck:
            return .connAck

        case .publish:
            return .publish(dup: false, qos: .atMostOnce, retain: false)

        case .pubAck:
            return .connAck

        case .pubRec:
            return .pubRec

        case .pubRel:
            return .pubRel

        case .pubComp:
            return .pubComp

        case .subscribe:
            return .subscribe

        case .subAck:
            return .subAck

        case .unsubscribe:
            return .unsubscribe

        case .unsubAck:
            return .unsubAck

        case .pingReq:
            return .pingReq

        case .pingResp:
            return .pingResp

        case .disconnect:
            return .disconnect

        case .auth:
            return .auth
        }
    }

    static private func validateFixedHeaderFlags(type: ControlPacketType, value: UInt8) -> Bool {
        switch type {
        case .connect,
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
            return value == 0

        case .pubRel, .subscribe, .unsubscribe:
            return value == 2

        // Publish packet doesn't have reserved flags
        case .publish:
            return true
        }
    }

    static private func makePublishFixedHeaderFlags(value: UInt8) -> FixedHeaderFlags? {
        let qosValue = (value >> 1) & 0b11
        guard let qos = QoS(rawValue: qosValue) else {
            return nil
        }
        let dup = ((value >> 3) & 1) == 1
        let retain = (value & 1) == 1
        return .publish(dup: dup, qos: qos, retain: retain)
    }
}

// MARK: - Equatable

extension FixedHeaderFlags: Equatable {}
