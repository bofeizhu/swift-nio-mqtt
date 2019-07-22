//
//  DataPayload.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 7/22/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

import struct Foundation.Data

/// Binary Data Payload
///
/// - Important:
///     The format of payload should be indicated
///     by Payload Format Indicator property
enum DataPayload {

    /// Unspecified Bytes
    case binary(data: Data)

    /// UTF-8 Encoded Character Data
    case utf8(stirng: String)
}
