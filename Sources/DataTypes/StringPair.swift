//
//  StringPair.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 6/17/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

/// A UTF-8 String Pair consists of two UTF-8 Encoded Strings. This data type is used to hold name-value pairs.
/// The first string serves as the name, and the second string contains the value.
struct StringPair {

    /// The name of this string pair
    let name: String

    /// The value of this string pair
    let value: String
}
