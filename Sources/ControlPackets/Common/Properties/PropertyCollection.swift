//
//  PropertyCollection.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 8/16/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

struct PropertyCollection {
    typealias ArrayType = [Property]

    private var properties: ArrayType = []

    /// Property Length
    ///
    /// Byte count of the properties
    /// - Note: *O(nlog(n))* runtime.
    /// - Important:
    ///     The Property Length does not include the bytes used to encode itself,
    ///     but includes the length of the Properties. If there are no properties,
    ///     this MUST be indicated by including a Property Length of zero.
    var propertyLength: VInt {
        return VInt(value: UInt(byteCount))
    }

    /// MQTT Byte Count
    ///
    /// Total number of bytes used to store the property collection in MQTT,
    /// including the byte count of property length.
    /// - Note: *O(nlog(n))* runtime.
    var mqttByteCount: Int {
        return propertyLength.bytes.count + byteCount
    }

    private var byteCount: Int = 0

    init() {}

    mutating func append(_ newProperty: Property) {
        properties.append(newProperty)
        byteCount += newProperty.byteCount
    }
}

extension PropertyCollection: Collection {
    typealias Index = ArrayType.Index
    typealias Element = Property

    var startIndex: Index { return properties.startIndex }
    var endIndex: Index { return properties.endIndex }

    subscript(index: Index) -> Iterator.Element {
        get { return properties[index] }
        set {
            let oldByteCount = properties[index].byteCount
            properties[index] = newValue
            byteCount += newValue.byteCount - oldByteCount
        }
    }

    func index(after i: Index) -> Index {
        return properties.index(after: i)
    }
}
