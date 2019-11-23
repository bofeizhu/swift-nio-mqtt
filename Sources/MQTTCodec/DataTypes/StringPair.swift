//
//  StringPair.swift
//  MQTTCodec
//
//  Created by Bofei Zhu on 6/17/19.
//  Copyright © 2019 Bofei Zhu. All rights reserved.
//

/// A UTF-8 String Pair consists of two UTF-8 Encoded Strings. This data type is used to hold name-value pairs.
/// The first string serves as the name, and the second string contains the value.
public struct StringPair {
    /// The name of this string pair
    public let name: String

    /// The value of this string pair
    public let value: String

    /// Byte count for MQTT String Pair
    var mqttByteCount: Int {
        return name.mqttByteCount + value.mqttByteCount
    }
}

// MARK: - Equatable

extension StringPair: Equatable {}
