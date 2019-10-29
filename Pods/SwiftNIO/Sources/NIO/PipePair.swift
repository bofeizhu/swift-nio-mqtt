//===----------------------------------------------------------------------===//
//
// This source file is part of the SwiftNIO open source project
//
// Copyright (c) 2019 Apple Inc. and the SwiftNIO project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of SwiftNIO project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

extension NIOFileHandle: Selectable {
}

final class PipePair: SocketProtocol {
    typealias SelectableType = NIOFileHandle

    let inputFD: NIOFileHandle
    let outputFD: NIOFileHandle

    init(inputFD: NIOFileHandle, outputFD: NIOFileHandle) throws {
        self.inputFD = inputFD
        self.outputFD = outputFD
        for fileHandle in [inputFD, outputFD] {
            try fileHandle.withUnsafeFileDescriptor {
                try NIOFileHandle.setNonBlocking(fileDescriptor: $0)
                try ignoreSIGPIPE(descriptor: $0)
            }
        }
    }

    var description: String {
        return "PipePair { in=\(inputFD), out=\(outputFD) }"
    }

    func connect(to address: SocketAddress) throws -> Bool {
        throw ChannelError.operationUnsupported
    }

    func finishConnect() throws {
        throw ChannelError.operationUnsupported
    }

    func write(pointer: UnsafeRawBufferPointer) throws -> IOResult<Int> {
        return try self.outputFD.withUnsafeFileDescriptor { fd in
            try Posix.write(descriptor: fd, pointer: pointer.baseAddress!, size: pointer.count)
        }
    }

    func writev(iovecs: UnsafeBufferPointer<IOVector>) throws -> IOResult<Int> {
        return try self.outputFD.withUnsafeFileDescriptor { fd in
            try Posix.writev(descriptor: fd, iovecs: iovecs)
        }
    }

    func sendto(pointer: UnsafeRawBufferPointer, destinationPtr: UnsafePointer<sockaddr>, destinationSize: socklen_t) throws -> IOResult<Int> {
        throw ChannelError.operationUnsupported
    }

    func read(pointer: UnsafeMutableRawBufferPointer) throws -> IOResult<Int> {
        return try self.inputFD.withUnsafeFileDescriptor { fd in
            try Posix.read(descriptor: fd, pointer: pointer.baseAddress!, size: pointer.count)
        }
    }

    func recvfrom(pointer: UnsafeMutableRawBufferPointer, storage: inout sockaddr_storage, storageLen: inout socklen_t) throws -> IOResult<Int> {
        throw ChannelError.operationUnsupported
    }

    func sendFile(fd: Int32, offset: Int, count: Int) throws -> IOResult<Int> {
        throw ChannelError.operationUnsupported
    }

    func recvmmsg(msgs: UnsafeMutableBufferPointer<MMsgHdr>) throws -> IOResult<Int> {
        throw ChannelError.operationUnsupported
    }

    func sendmmsg(msgs: UnsafeMutableBufferPointer<MMsgHdr>) throws -> IOResult<Int> {
        throw ChannelError.operationUnsupported
    }

    func shutdown(how: Shutdown) throws {
        switch how {
        case .RD:
            try self.inputFD.close()
        case .WR:
            try self.outputFD.close()
        case .RDWR:
            try self.close()
        }
    }

    var isOpen: Bool {
        return self.inputFD.isOpen || self.outputFD.isOpen
    }

    func close() throws {
        guard self.inputFD.isOpen || self.outputFD.isOpen else {
            throw ChannelError.alreadyClosed
        }
        let r1 = Result {
            if self.inputFD.isOpen {
                try self.inputFD.close()
            }
        }
        let r2 = Result {
            if self.outputFD.isOpen {
                try self.outputFD.close()
            }
        }
        try r1.get()
        try r2.get()
    }

    func bind(to address: SocketAddress) throws {
        throw ChannelError.operationUnsupported
    }

    func localAddress() throws -> SocketAddress {
        throw ChannelError.operationUnsupported
    }

    func remoteAddress() throws -> SocketAddress {
        throw ChannelError.operationUnsupported
    }

    func setOption<T>(level: Int32, name: Int32, value: T) throws {
        throw ChannelError.operationUnsupported
    }

    func getOption<T>(level: Int32, name: Int32) throws -> T {
        throw ChannelError.operationUnsupported
    }
}
