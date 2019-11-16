//
//  PubRelPacket+ReasonCode.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 7/28/19.
//  Copyright © 2019 Bofei Zhu. All rights reserved.
//

extension PubRelPacket {

    /// PUBREL Reason Code
    enum ReasonCode: ReasonCodeValue {

        /// Success
        ///
        /// Message released.
        case success = 0

        /// Packet Identifier Not Found
        ///
        /// The Packet Identifier is not known. This is not an error during recovery,
        /// but at other times indicates a mismatch between the Session State on the Client and Server.
        case packetIdentifierNotFound = 146
    }
}
