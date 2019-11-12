//
//  String+Additions.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 8/12/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

extension String: MQTTByteRepresentable {

    /// Byte count for MQTT UTF-8 Encoded Strings, including the Two Byte Integer length field
    ///
    /// In MQTT, UTF-8 Encoded Strings is prefixed with a Two Byte Integer length field that
    /// gives the number of bytes in a UTF-8 encoded string itself.
    /// Consequently, the maximum size of a UTF-8 Encoded String is 65,535 bytes.
    var mqttByteCount: Int {
        return utf8.count + 2
    }
}
