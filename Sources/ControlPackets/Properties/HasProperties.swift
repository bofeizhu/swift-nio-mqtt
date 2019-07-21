//
//  HasProperties.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 7/21/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

protocol HasProperties {

    /// A sequence of properties
    var properties: [Property] { get }

    // TODO: Add valid properties set
}
