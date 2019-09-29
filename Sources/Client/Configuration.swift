//
//  Configuration.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 8/30/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

extension MQTT {
    /// The configuration for a connection.
    public struct Configuration {
        /// The
        public var qos: QoS

        public init(qos: QoS = .atMostOnce) {
            self.qos = qos
        }
    }
}
