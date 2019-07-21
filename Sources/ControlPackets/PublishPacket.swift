//
//  PublishPacket.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 6/18/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

/// Quality of service. Level of assurance for delivery of an Application Message.
public enum QoS: UInt8 {

    /// At most once delivery
    case atMostOnce = 0

    /// At least once delivery
    case atLeastOnce

    /// Exactly once delivery
    case exactlyOnce
}

struct PublishPacket {

}
