//
//  DataPayload.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 7/22/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

import NIO
import struct Foundation.Data

/// Binary Data Payload
///
/// - Important:
///     The format of payload should be indicated
///     by Payload Format Indicator property.
enum DataPayload {

    /// Unspecified Bytes
    case binary(data: Data)

    /// UTF-8 Encoded Character Data
    case utf8(stirng: String)

    /// Zero Length Payload
    case empty
}

extension ByteBuffer {

    mutating func write(_ payload: DataPayload) -> Int {

        switch payload {
        case let .binary(data):
            return writeBytes(data)
        case let .utf8(string):
            return writeString(string)
        case .empty:
            return 0
        }
    }

    mutating func readDataPayload(length: Int, isUTF8Encoded: Bool = false) -> DataPayload? {

        guard length > 0 else { return .empty }

        if isUTF8Encoded {
            guard let string = readString(length: length) else {
                return nil
            }
            return .utf8(stirng: string)
        } else {
            guard let data = readBytes(length: length) else {
                return nil
            }
            return .binary(data: Data(data))
        }
    }
}
