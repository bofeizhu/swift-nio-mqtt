//
//  MQTT+Configuration.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 8/30/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

extension MQTT {

    public struct Configuration {

        public var qos: QoS

        public init(qos: QoS = .level0) {
            self.qos = qos
        }
    }
}
