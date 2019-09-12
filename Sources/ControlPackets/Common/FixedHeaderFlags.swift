//
//  FixedHeaderFlags.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 8/16/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

/// The last four bits in the Fixed Header contain flags specific to each MQTT Control Packet type.
enum FixedHeaderFlags {

    case reserved(value: UInt8)

    case publish(dup: Bool, qos: QoS, retain: Bool)

    init?(type: ControlPacketType) {
        let value = FixedHeaderFlags.reservedFlagsValue(of: type)
        switch type {
        case .publish:
            let qosValue = (value >> 1) & 0b11
            guard let qos = QoS(rawValue: qosValue) else {
                return nil
            }
            let dup = ((value >> 3) & 1) == 1
            let retain = (value & 1) == 1
            self = .publish(dup: dup, qos: qos, retain: retain)

        default:
            self = .reserved(value: value )
        }
    }

    var value: UInt8 {
        switch self {
        case let .reserved(flags):
            return flags

        case let .publish(dup, qos, retain):
            let bit0: UInt8 = retain ? 1 : 0
            let bit12 = qos.rawValue
            let bit3: UInt8 = dup ? 1 : 0
            return (bit3 << 3) | (bit12 << 1) | bit0
        }
    }

    static func reservedFlagsValue(of type: ControlPacketType) -> UInt8 {
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
            return 0

        case .pubRel, .subscribe, .unsubscribe:
            return 2

        // Reserved & Publish packet doesn't have reserved flags
        case .reserved, .publish:
            return 0
        }
    }

    static func validate(type: ControlPacketType, value: UInt8) -> Bool {
        switch type {
        case .publish:
            return true

        case .reserved:
            return false

        default:
            return FixedHeaderFlags.reservedFlagsValue(of: type) == value
        }
    }
}

// MARK: - Equatable

extension FixedHeaderFlags: Equatable {}
