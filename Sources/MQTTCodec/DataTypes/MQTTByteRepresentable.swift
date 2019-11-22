//
//  MQTTByteRepresentable.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 8/21/19.
//  Copyright © 2019 Bofei Zhu. All rights reserved.
//

/// A type that can be converted to and from raw bytes in MQTT.
protocol MQTTByteRepresentable {
    /// The number of bytes in the object.
    var mqttByteCount: Int { get }
}
