//
//  Data+Additions.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 8/12/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

import struct Foundation.Data

extension Data: MQTTByteRepresentable {
    /// Byte count for MQTT binary data, including the Two Byte Integer length field
    ///
    /// In MQTT, Binary Data is represented by a Two Byte Integer length which indicates the number of data bytes,
    /// followed by that number of bytes. Thus, the length of Binary Data is limited to the range of 0 to 65,535 Bytes.
    var mqttByteCount: Int {
        return count + 2
    }
}
