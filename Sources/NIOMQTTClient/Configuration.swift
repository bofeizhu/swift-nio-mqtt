//
//  Configuration.swift
//  NIOMQTTClient
//
//  Created by Bofei Zhu on 8/30/19.
//  Copyright © 2019 Bofei Zhu. All rights reserved.
//

import MQTTCodec
import struct Foundation.Data

extension MQTTClient {
    /// The configuration for a connection.
    public struct Configuration {
        /// The host to connect to.
        public var host: String

        /// The port to connect to.
        public var port: Int

        /// The client identifier.
        ///
        /// The Client Identifier (ClientID) identifies the Client to the Server.
        /// Each Client connecting to the Server has a unique ClientID.
        /// The ClientID MUST be used by Clients and by Servers to identify state
        /// that they hold relating to this MQTT Session between the Client and the Server [
        public var clientId: String

        /// The QoS level for delivery of Application Messages.
        public var qos: QoS

        /// The username of the client.
        public var username: String?

        /// The password of the client.
        ///
        /// The Password field is Binary Data.
        /// Although this field is called Password, it can be used to carry any credential information.
        public var password: Data?

        /// The connection backoff configuration.
        ///
        /// - Note: If no connection retrying is required then this should be `nil`.
        public var connectionBackoff: ConnectionBackoff?

        /// Create a `Configuration` with some pre-defined defaults.
        ///
        /// - Parameter host: The host to connect to.
        /// - Parameter port: The port to connect to.
        /// - Parameter qos: The QoS level for delivery of Application Messages.
        /// - Parameter connectionBackoff: The connection backoff configuration to use.
        public init(
            host: String,
            port: Int,
            clientId: String,
            qos: QoS = .atMostOnce,
            username: String? = nil,
            password: Data? = nil,
            connectionBackoff: ConnectionBackoff? = ConnectionBackoff()
        ) {
            self.host = host
            self.port = port
            self.clientId = clientId
            self.qos = qos
            self.username = username
            self.password = password
            self.connectionBackoff = connectionBackoff
        }
    }
}
