//===----------------------------------------------------------------------===//
//
// This source file is part of the SwiftNIO open source project
//
// Copyright (c) 2017-2018 Apple Inc. and the SwiftNIO project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of SwiftNIO project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

/// A DNS resolver built on top of the libc `getaddrinfo` function.
///
/// This is the lowest-common-denominator resolver available to NIO. It's not really a very good
/// solution because the `getaddrinfo` call blocks during the DNS resolution, meaning that this resolver
/// will block an event loop thread for as long as it takes to perform the getaddrinfo call. However, it
/// does have the advantage of automatically conforming to RFC 6724, which removes some of the work
/// needed to implement it.
///
/// This resolver is a single-use object: it can only be used to perform a single host resolution.
import CNIOLinux

internal class GetaddrinfoResolver: Resolver {
    private let v4Future: EventLoopPromise<[SocketAddress]>
    private let v6Future: EventLoopPromise<[SocketAddress]>
    private let aiSocktype: CInt
    private let aiProtocol: CInt

    /// Create a new resolver.
    ///
    /// - parameters:
    ///     - loop: The `EventLoop` whose thread this resolver will block.
    ///     - aiSocktype: The sock type to use as hint when calling getaddrinfo.
    ///     - aiProtocol: the protocol to use as hint when calling getaddrinfo.
    init(loop: EventLoop, aiSocktype: CInt, aiProtocol: CInt) {
        self.v4Future = loop.makePromise()
        self.v6Future = loop.makePromise()
        self.aiSocktype = aiSocktype
        self.aiProtocol = aiProtocol
    }

    /// Initiate a DNS A query for a given host.
    ///
    /// Due to the nature of `getaddrinfo`, we only actually call the function once, in the AAAA query.
    /// That means this just returns the future for the A results, which in practice will always have been
    /// satisfied by the time this function is called.
    ///
    /// - parameters:
    ///     - host: The hostname to do an A lookup on.
    ///     - port: The port we'll be connecting to.
    /// - returns: An `EventLoopFuture` that fires with the result of the lookup.
    func initiateAQuery(host: String, port: Int) -> EventLoopFuture<[SocketAddress]> {
        return v4Future.futureResult
    }

    /// Initiate a DNS AAAA query for a given host.
    ///
    /// Due to the nature of `getaddrinfo`, we only actually call the function once, in this function.
    /// That means this function call actually blocks: sorry!
    ///
    /// - parameters:
    ///     - host: The hostname to do an AAAA lookup on.
    ///     - port: The port we'll be connecting to.
    /// - returns: An `EventLoopFuture` that fires with the result of the lookup.
    func initiateAAAAQuery(host: String, port: Int) -> EventLoopFuture<[SocketAddress]> {
        resolve(host: host, port: port)
        return v6Future.futureResult
    }

    /// Cancel all outstanding DNS queries.
    ///
    /// This method is called whenever queries that have not completed no longer have their
    /// results needed. The resolver should, if possible, abort any outstanding queries and
    /// clean up their state.
    ///
    /// In the getaddrinfo case this is a no-op, as the resolver blocks.
    func cancelQueries() { }

    /// Perform the DNS queries and record the result.
    ///
    /// - parameters:
    ///     - host: The hostname to do the DNS queries on.
    ///     - port: The port we'll be connecting to.
    private func resolve(host: String, port: Int) {
        var info: UnsafeMutablePointer<addrinfo>?

        var hint = addrinfo()
        hint.ai_socktype = self.aiSocktype
        hint.ai_protocol = self.aiProtocol
        guard getaddrinfo(host, String(port), &hint, &info) == 0 else {
            self.fail(SocketAddressError.unknown(host: host, port: port))
            return
        }

        if let info = info {
            parseResults(info, host: host)
            freeaddrinfo(info)
        } else {
            /* this is odd, getaddrinfo returned NULL */
            self.fail(SocketAddressError.unsupported)
        }
    }

    /// Parses the DNS results from the `addrinfo` linked list.
    ///
    /// - parameters:
    ///     - info: The pointer to the first of the `addrinfo` structures in the list.
    ///     - host: The hostname we resolved.
    private func parseResults(_ info: UnsafeMutablePointer<addrinfo>, host: String) {
        var info = info
        var v4Results = [SocketAddress]()
        var v6Results = [SocketAddress]()

        while true {
            switch info.pointee.ai_family {
            case AF_INET:
                info.pointee.ai_addr.withMemoryRebound(to: sockaddr_in.self, capacity: 1) { ptr in
                    v4Results.append(.init(ptr.pointee, host: host))
                }
            case AF_INET6:
                info.pointee.ai_addr.withMemoryRebound(to: sockaddr_in6.self, capacity: 1) { ptr in
                    v6Results.append(.init(ptr.pointee, host: host))
                }
            default:
                self.fail(SocketAddressError.unsupported)
                return
            }

            guard let nextInfo = info.pointee.ai_next else {
                break
            }

            info = nextInfo
        }

        v6Future.succeed(v6Results)
        v4Future.succeed(v4Results)
    }

    /// Record an error and fail the lookup process.
    ///
    /// - parameters:
    ///     - error: The error encountered during lookup.
    private func fail(_ error: Error) {
        self.v6Future.fail(error)
        self.v4Future.fail(error)
    }
}
