//
//  PropertyCollection.swift
//  MQTTCodec
//
//  Created by Bofei Zhu on 8/16/19.
//  Copyright © 2019 Bofei Zhu. All rights reserved.
//

public struct PropertyCollection {
    public typealias ArrayType = [Property]

    private var properties: ArrayType = []

    /// Property Length
    ///
    /// Byte count of the properties
    /// - Important:
    ///     The Property Length does not include the bytes used to encode itself,
    ///     but includes the length of the Properties. If there are no properties,
    ///     this MUST be indicated by including a Property Length of zero.
    /// - Complexity: O(*log(n)*)
    var propertyLength: VInt {
        return VInt(value: UInt(byteCount))
    }

    // MARK: MQTT Attributes

    public var isPayloadUTF8Encoded: Bool = false

    public var serverKeepAlive: UInt16?

    // MARK: Private

    private var byteCount: Int = 0

    public init() {}

    /// Adds a property to the end of the collection.
    ///
    /// - Parameter newProperty: The property to append to the collection.
    public mutating func append(_ newProperty: Property) {
        properties.append(newProperty)
        byteCount += newProperty.mqttByteCount

        switch newProperty {
        case let .payloadFormatIndicator(isUTF8):
            isPayloadUTF8Encoded = isUTF8

        case let .serverKeepAlive(interval):
            serverKeepAlive = interval

        default:
            break
        }
    }
}

// MARK: - Collection

extension PropertyCollection: Collection {
    public typealias Index = ArrayType.Index
    public typealias Element = Property

    public var startIndex: Index { return properties.startIndex }
    public var endIndex: Index { return properties.endIndex }

    public subscript(index: Index) -> Element {
        return properties[index]
    }

    public func index(after i: Index) -> Index {
        return properties.index(after: i)
    }
}

// MARK: - MQTTByteRepresentable

extension PropertyCollection: MQTTByteRepresentable {

    /// MQTT Byte Count
    ///
    /// Total number of bytes used to store the property collection in MQTT,
    /// including the byte count of property length.
    /// - Complexity: O(*log(n)*)
    var mqttByteCount: Int {
        return propertyLength.mqttByteCount + byteCount
    }
}
