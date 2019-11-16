//
//  MQTTError.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 9/26/19.
//  Copyright © 2019 Bofei Zhu. All rights reserved.
//

public struct MQTTError: Error {
    /// The type of the error.
    public let type: MQTTErrorType

    /// The status message of the error.
    public let message: String?

    // MARK: Frequently used "default" errors.

    /// Unavailable.
    public static let unavailable = MQTTError(type: .unavailable, message: "The connection is currently unavailable.")

    /// Internal Error.
    public static let internalError = MQTTError(type: .internalError, message: "Unknown internal error.")
}

public enum MQTTErrorType {
    /// The connection is currently unavailable.
    case unavailable

    /// Internal Error.
    case internalError

    /// Malformed Packet.
    case malformedPacket

    /// Protocol Error.
    case protocolError
}

public protocol MQTTErrorTransformable: Error {
    func asMQTTError() -> MQTTError
}

extension MQTTCodingError: MQTTErrorTransformable {
    func asMQTTError() -> MQTTError {
        return MQTTError(type: .malformedPacket, message: errorDescription)
    }
}
