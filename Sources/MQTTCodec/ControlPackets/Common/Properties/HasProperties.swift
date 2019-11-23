//
//  HasProperties.swift
//  MQTTCodec
//
//  Created by Bofei Zhu on 7/21/19.
//  Copyright © 2019 Bofei Zhu. All rights reserved.
//

protocol HasProperties {
    /// A sequence of properties
    var properties: PropertyCollection { get }

    // TODO: Add valid properties set
}
