//
//  String+Additions.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 8/12/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

extension String {

    /// Byte count for MQTT UTF-8 Encoded Strings, including the Two Byte Integer length field
    var mqttByteCount: Int {
        return utf8.count + 2
    }
}
