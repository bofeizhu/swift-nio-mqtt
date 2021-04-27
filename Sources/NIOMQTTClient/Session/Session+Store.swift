//
//  Session+Store.swift
//  NIOMQTTClient
//
//  Created by Bofei Zhu on 10/16/19.
//  Copyright © 2019 Bofei Zhu. All rights reserved.
//

import Collections

extension Session {
    /// Store for unacknowledged QoS level-1 & QoS level-2 packets.
    struct Store<Element>: Collection {
        typealias Index = Int
        typealias Identifier = UInt16

        var startIndex: Int { dictionary.elements.startIndex }

        var endIndex: Int { dictionary.elements.endIndex }

        private var dictionary: OrderedDictionary<Identifier, Element> = [:]

        mutating func append(_ element: Element, withIdentifier identifier: Identifier) {
            dictionary[identifier] = element
        }

        @discardableResult
        mutating func removeElement(forIdentifier identifier: Identifier) -> Element? {
            dictionary.removeValue(forKey: identifier)
        }

        subscript(key: UInt16) -> Element? {
            return dictionary[key]
        }

        subscript(position: Int) -> Element {
            return dictionary.elements[position].value
        }

        func index(after i: Int) -> Int {
            return dictionary.elements.index(after: i)
        }
    }
}
