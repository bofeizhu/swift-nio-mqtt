//
//  Session+Store.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 10/16/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

extension Session {
    /// Store for unacknowledged QoS level-1 & QoS level-2 packets.
    struct Store<Element>: Collection {
        typealias Index = Int
        typealias Identifier = UInt16

        var startIndex: Int { orders.startIndex }

        var endIndex: Int { orders.endIndex }

        private var orders: [Identifier] = []

        private var dictionary: [Identifier: (Index, Element)] = [:]

        mutating func append(_ element: Element, withIdentifier identifier: Identifier) {
            dictionary[identifier] = (orders.endIndex, element)
            orders.append(identifier)
        }

        @discardableResult
        mutating func removeElement(forIdentifier identifier: Identifier) -> Element? {
            guard let (index, element) = dictionary[identifier] else {
                return nil
            }
            orders.remove(at: index)
            return element
        }

        subscript(key: UInt16) -> Element? {
            return dictionary[key]?.1
        }

        subscript(position: Int) -> Element {
            return dictionary[orders[position]]!.1
        }

        func index(after i: Int) -> Int {
            return orders.index(after: i)
        }
    }
}
