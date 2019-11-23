//
//  UnsubscribePacketBuilder.swift
//  MQTTCodec
//
//  Created by Bofei Zhu on 11/13/19.
//  Copyright © 2019 Bofei Zhu. All rights reserved.
//

public final class UnsubscribePacketBuilder {

    private var packetIdentifier: UInt16

    private var topicFilters: [String] = []

    private var properties = PropertyCollection()

    public init(packetIdentifier: UInt16) {
        self.packetIdentifier = packetIdentifier
    }

    public func addUnsubscription(topicFilter: String) -> UnsubscribePacketBuilder {
        topicFilters.append(topicFilter)
        return self
    }

    /// Build UNSUBSCRIBE packet.
    ///
    /// - Returns: A UNSUBSCRIBE packet.
    public func build() -> UnsubscribePacket {
        let variableHeader = UnsubscribePacket.VariableHeader(
            packetIdentifier: packetIdentifier,
            properties: PropertyCollection())
        let payload = UnsubscribePacket.Payload(topicFilters: topicFilters)
        return UnsubscribePacket(variableHeader: variableHeader, payload: payload)
    }
}
