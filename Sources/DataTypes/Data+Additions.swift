//
//  Data+Additions.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 8/12/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

import struct Foundation.Data

extension Data {

    /// Byte count for MQTT binary data, including the Two Byte Integer length field
    var mqttByteCount: Int {
        return count + 2
    }
}
