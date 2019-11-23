//
//  QoS.swift
//  MQTTCodec
//
//  Created by Bofei Zhu on 7/22/19.
//  Copyright © 2019 Bofei Zhu. All rights reserved.
//

/// Quality of service.
///
/// Level of assurance for delivery of an Application Message.
public enum QoS: UInt8 {
    /// At most once delivery.
    case atMostOnce = 0

    /// At least once delivery.
    case atLeastOnce

    /// Exactly once delivery.
    case exactlyOnce
}

// MARK: - QoS

extension QoS: Equatable {}
