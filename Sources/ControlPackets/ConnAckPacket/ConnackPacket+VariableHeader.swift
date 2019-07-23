//
//  ConnAckPacket+VariableHeader.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 7/21/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

extension ConnAckPacket: VariableHeaderPacket {

    /// The Variable Header for CONNACK Packet
    struct VariableHeader: HasProperties {

        // MARK: Connect Acknowledge Flags

        /// Connect Acknowledge Flags
        ///
        /// Byte 1 is the "Connect Acknowledge Flags". Bits 7-1 are reserved and MUST be set to 0
        /// Bit 0 is the Session Present Flag.
        let connectAcknowledgeFlags: UInt8

        /// Session Present
        ///
        /// Position: bit 0 of the Connect Acknowledge Flags.
        var sessionPresent: Bool {
            return (connectAcknowledgeFlags & 1) == 1
        }

        // MARK: Connect Reason Code

        /// Connect Reason Code
        let connectReasonCode: ConnectReasonCode

        // MARK: Properties

        /// Properties
        let properties: [Property]
    }
}
