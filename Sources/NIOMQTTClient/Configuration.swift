//
//  Configuration.swift
//  NIOMQTTClient
//
//  Created by Bofei Zhu on 8/30/19.
//  Copyright © 2019 Bofei Zhu. All rights reserved.
//

import MQTTCodec

extension MQTTClient {
    /// The configuration for a connection.
    public struct Configuration {
        /// The host to connect to.
        public var host: String

        /// The port to connect to.
        public var port: Int

        /// The QoS level for delivery of Application Messages.
        public var qos: QoS
        
        /// The client-ID
        public var clientId: String
        
        /// The username
        public var username: String
        
        /// The password of the user
        public var password: String

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
            qos: QoS = .atMostOnce,
            connectionBackoff: ConnectionBackoff? = ConnectionBackoff()
        ) {
            self.host = host
            self.port = port
            self.qos = qos
            self.connectionBackoff = connectionBackoff
            
            self.clientId = "HealthTap"
            self.username = ""
            self.password = ""
        }
        
        public init(
            host: String,
            port: Int,
            qos: QoS = .atMostOnce,
            clientId: String,
            username: String,
            password: String,
            connectionBackoff: ConnectionBackoff? = ConnectionBackoff()
        ) {
            self.host = host
            self.port = port
            self.qos = qos
            self.clientId = clientId
            self.username = username
            self.password = password
            self.connectionBackoff = connectionBackoff
        }
    }
}
