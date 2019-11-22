//
//  Configuration.swift
//  NIOMQTT
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
        }
    }
}
