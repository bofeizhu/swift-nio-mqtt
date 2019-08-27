//
//  PublishPacket+Payload.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 7/22/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

import NIO
import struct Foundation.Data

extension PublishPacket: PayloadPacket {

    /// Binary Data Payload
    ///
    /// - Important:
    ///     The format of payload should be indicated by Payload Format Indicator property.
    enum Payload: MQTTByteRepresentable {

        /// Unspecified Bytes
        case binary(data: Data)

        /// UTF-8 Encoded Character Data
        case utf8(stirng: String)

        /// Zero Length Payload
        case empty

        var mqttByteCount: Int {

           switch self {

           case let .binary(data):
               return data.count

           case let .utf8(string):
               return string.utf8.count

           case .empty:
               return 0
           }
        }
    }
}
