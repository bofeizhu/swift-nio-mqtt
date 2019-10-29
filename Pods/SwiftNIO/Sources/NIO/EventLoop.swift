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

import NIOConcurrencyHelpers
import Dispatch

/// Returned once a task was scheduled on the `EventLoop` for later execution.
///
/// A `Scheduled` allows the user to either `cancel()` the execution of the scheduled task (if possible) or obtain a reference to the `EventLoopFuture` that
/// will be notified once the execution is complete.
public struct Scheduled<T> {
    private let promise: EventLoopPromise<T>

    public init(promise: EventLoopPromise<T>, cancellationTask: @escaping () -> Void) {
        self.promise = promise
        promise.futureResult.whenFailure { error in
            guard let err = error as? EventLoopError else {
                return
            }
            if err == .cancelled {
                cancellationTask()
            }
        }
    }

    /// Try to cancel the execution of the scheduled task.
    ///
    /// Whether this is successful depends on whether the execution of the task already begun.
    ///  This means that cancellation is not guaranteed.
    public func cancel() {
        promise.fail(EventLoopError.cancelled)
    }

    /// Returns the `EventLoopFuture` which will be notified once the execution of the scheduled task completes.
    public var futureResult: EventLoopFuture<T> {
        return promise.futureResult
    }
}

/// Returned once a task was scheduled to be repeatedly executed on the `EventLoop`.
///
/// A `RepeatedTask` allows the user to `cancel()` the repeated scheduling of further tasks.
public final class RepeatedTask {
    private let delay: TimeAmount
    private let eventLoop: EventLoop
    private let cancellationPromise: EventLoopPromise<Void>?
    private var scheduled: Scheduled<EventLoopFuture<Void>>?
    private var task: ((RepeatedTask) -> EventLoopFuture<Void>)?

    internal init(interval: TimeAmount, eventLoop: EventLoop, cancellationPromise: EventLoopPromise<Void>? = nil, task: @escaping (RepeatedTask) -> EventLoopFuture<Void>) {
        self.delay = interval
        self.eventLoop = eventLoop
        self.cancellationPromise = cancellationPromise
        self.task = task
    }

    internal func begin(in delay: TimeAmount) {
        if self.eventLoop.inEventLoop {
            self.begin0(in: delay)
        } else {
            self.eventLoop.execute {
                self.begin0(in: delay)
            }
        }
    }

    private func begin0(in delay: TimeAmount) {
        self.eventLoop.assertInEventLoop()
        guard let task = self.task else {
            return
        }
        self.scheduled = self.eventLoop.scheduleTask(in: delay) {
            task(self)
        }
        self.reschedule()
    }

    /// Try to cancel the execution of the repeated task.
    ///
    /// Whether the execution of the task is immediately canceled depends on whether the execution of a task has already begun.
    ///  This means immediate cancellation is not guaranteed.
    ///
    /// The safest way to cancel is by using the passed reference of `RepeatedTask` inside the task closure.
    ///
    /// If the promise parameter is not `nil`, the passed promise is fulfilled when cancellation is complete.
    /// Passing a promise does not prevent fulfillment of any promise provided on original task creation.
    public func cancel(promise: EventLoopPromise<Void>? = nil) {
        if self.eventLoop.inEventLoop {
            self.cancel0(localCancellationPromise: promise)
        } else {
            self.eventLoop.execute {
                self.cancel0(localCancellationPromise: promise)
            }
        }
    }

    private func cancel0(localCancellationPromise: EventLoopPromise<Void>?) {
        self.eventLoop.assertInEventLoop()
        self.scheduled?.cancel()
        self.scheduled = nil
        self.task = nil

        // Possible states at this time are:
        //  1) Task is scheduled but has not yet executed.
        //  2) Task is currently executing and invoked `cancel()` on itself.
        //  3) Task is currently executing and `cancel0()` has been reentrantly invoked.
        //  4) NOT VALID: Task is currently executing and has NOT invoked `cancel()` (`EventLoop` guarantees serial execution)
        //  5) NOT VALID: Task has completed execution in a success state (`reschedule()` ensures state #2).
        //  6) Task has completed execution in a failure state.
        //  7) Task has been fully cancelled at a previous time.
        //
        // It is desirable that the task has fully completed any execution before any cancellation promise is
        // fulfilled. States 2 and 3 occur during execution, so the requirement is implemented by deferring
        // fulfillment to the next `EventLoop` cycle. The delay is harmless to other states and distinguishing
        // them from 2 and 3 is not practical (or necessarily possible), so is used unconditionally. Check the
        // promises for nil so as not to otherwise invoke `execute()` unnecessarily.
        if self.cancellationPromise != nil || localCancellationPromise != nil {
            self.eventLoop.execute {
                self.cancellationPromise?.succeed(())
                localCancellationPromise?.succeed(())
            }
        }
    }

    private func reschedule() {
        self.eventLoop.assertInEventLoop()
        guard let scheduled = self.scheduled else {
            return
        }

        scheduled.futureResult.whenSuccess { future in
            future.whenComplete { (_: Result<Void, Error>) in
                self.reschedule0()
            }
        }

        scheduled.futureResult.whenFailure { (_: Error) in
            self.cancel0(localCancellationPromise: nil)
        }
    }

    private func reschedule0() {
        self.eventLoop.assertInEventLoop()
        guard self.task != nil else {
            return
        }
        self.scheduled = self.eventLoop.scheduleTask(in: self.delay) {
            // we need to repeat this as we might have been cancelled in the meantime
            guard let task = self.task else {
                return self.eventLoop.makeSucceededFuture(())
            }
            return task(self)
        }
        self.reschedule()
    }
}

/// An iterator over the `EventLoop`s forming an `EventLoopGroup`.
///
/// Usually returned by an `EventLoopGroup`'s `makeIterator()` method.
///
///     let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
///     group.makeIterator().forEach { loop in
///         // Do something with each loop
///     }
///
public struct EventLoopIterator: Sequence, IteratorProtocol {
    public typealias Element = EventLoop
    private var eventLoops: IndexingIterator<[EventLoop]>

    /// Create an `EventLoopIterator` from an array of `EventLoop`s.
    public init(_ eventLoops: [EventLoop]) {
        self.eventLoops = eventLoops.makeIterator()
    }

    /// Advances to the next `EventLoop` and returns it, or `nil` if no next element exists.
    ///
    /// - returns: The next `EventLoop` if a next element exists; otherwise, `nil`.
    public mutating func next() -> EventLoop? {
        return self.eventLoops.next()
    }
}

/// An EventLoop processes IO / tasks in an endless loop for `Channel`s until it's closed.
///
/// Usually multiple `Channel`s share the same `EventLoop` for processing IO / tasks and so share the same processing `NIOThread`.
/// For a better understanding of how such an `EventLoop` works internally the following pseudo code may be helpful:
///
/// ```
/// while eventLoop.isOpen {
///     /// Block until there is something to process for 1...n Channels
///     let readyChannels = blockUntilIoOrTasksAreReady()
///     /// Loop through all the Channels
///     for channel in readyChannels {
///         /// Process IO and / or tasks for the Channel.
///         /// This may include things like:
///         ///    - accept new connection
///         ///    - connect to a remote host
///         ///    - read from socket
///         ///    - write to socket
///         ///    - tasks that were submitted via EventLoop methods
///         /// and others.
///         processIoAndTasks(channel)
///     }
/// }
/// ```
///
/// Because an `EventLoop` may be shared between multiple `Channel`s it's important to _NOT_ block while processing IO / tasks. This also includes long running computations which will have the same
/// effect as blocking in this case.
public protocol EventLoop: EventLoopGroup {
    /// Returns `true` if the current `NIOThread` is the same as the `NIOThread` that is tied to this `EventLoop`. `false` otherwise.
    var inEventLoop: Bool { get }

    /// Submit a given task to be executed by the `EventLoop`
    func execute(_ task: @escaping () -> Void)

    /// Submit a given task to be executed by the `EventLoop`. Once the execution is complete the returned `EventLoopFuture` is notified.
    ///
    /// - parameters:
    ///     - task: The closure that will be submitted to the `EventLoop` for execution.
    /// - returns: `EventLoopFuture` that is notified once the task was executed.
    func submit<T>(_ task: @escaping () throws -> T) -> EventLoopFuture<T>

    /// Schedule a `task` that is executed by this `SelectableEventLoop` at the given time.
    @discardableResult
    func scheduleTask<T>(deadline: NIODeadline, _ task: @escaping () throws -> T) -> Scheduled<T>

    /// Schedule a `task` that is executed by this `SelectableEventLoop` after the given amount of time.
    @discardableResult
    func scheduleTask<T>(in: TimeAmount, _ task: @escaping () throws -> T) -> Scheduled<T>

    /// Checks that this call is run from the `EventLoop`. If this is called from within the `EventLoop` this function
    /// will have no effect, if called from outside the `EventLoop` it will crash the process with a trap.
    func preconditionInEventLoop(file: StaticString, line: UInt)
}

/// Represents a time _interval_.
///
/// - note: `TimeAmount` should not be used to represent a point in time.
public struct TimeAmount: Equatable {
    @available(*, deprecated, message: "This typealias doesn't serve any purpose. Please use Int64 directly.")
    public typealias Value = Int64

    /// The nanoseconds representation of the `TimeAmount`.
    public let nanoseconds: Int64

    private init(_ nanoseconds: Int64) {
        self.nanoseconds = nanoseconds
    }

    /// Creates a new `TimeAmount` for the given amount of nanoseconds.
    ///
    /// - parameters:
    ///     - amount: the amount of nanoseconds this `TimeAmount` represents.
    /// - returns: the `TimeAmount` for the given amount.
    public static func nanoseconds(_ amount: Int64) -> TimeAmount {
        return TimeAmount(amount)
    }

    /// Creates a new `TimeAmount` for the given amount of microseconds.
    ///
    /// - parameters:
    ///     - amount: the amount of microseconds this `TimeAmount` represents.
    /// - returns: the `TimeAmount` for the given amount.
    public static func microseconds(_ amount: Int64) -> TimeAmount {
        return TimeAmount(amount * 1000)
    }

    /// Creates a new `TimeAmount` for the given amount of milliseconds.
    ///
    /// - parameters:
    ///     - amount: the amount of milliseconds this `TimeAmount` represents.
    /// - returns: the `TimeAmount` for the given amount.
    public static func milliseconds(_ amount: Int64) -> TimeAmount {
        return TimeAmount(amount * 1000 * 1000)
    }

    /// Creates a new `TimeAmount` for the given amount of seconds.
    ///
    /// - parameters:
    ///     - amount: the amount of seconds this `TimeAmount` represents.
    /// - returns: the `TimeAmount` for the given amount.
    public static func seconds(_ amount: Int64) -> TimeAmount {
        return TimeAmount(amount * 1000 * 1000 * 1000)
    }

    /// Creates a new `TimeAmount` for the given amount of minutes.
    ///
    /// - parameters:
    ///     - amount: the amount of minutes this `TimeAmount` represents.
    /// - returns: the `TimeAmount` for the given amount.
    public static func minutes(_ amount: Int64) -> TimeAmount {
        return TimeAmount(amount * 1000 * 1000 * 1000 * 60)
    }

    /// Creates a new `TimeAmount` for the given amount of hours.
    ///
    /// - parameters:
    ///     - amount: the amount of hours this `TimeAmount` represents.
    /// - returns: the `TimeAmount` for the given amount.
    public static func hours(_ amount: Int64) -> TimeAmount {
        return TimeAmount(amount * 1000 * 1000 * 1000 * 60 * 60)
    }
}

extension TimeAmount: Comparable {
    public static func < (lhs: TimeAmount, rhs: TimeAmount) -> Bool {
        return lhs.nanoseconds < rhs.nanoseconds
    }
}

extension TimeAmount {
    public static func + (lhs: TimeAmount, rhs: TimeAmount) -> TimeAmount {
        return TimeAmount(lhs.nanoseconds + rhs.nanoseconds)
    }

    public static func - (lhs: TimeAmount, rhs: TimeAmount) -> TimeAmount {
        return TimeAmount(lhs.nanoseconds - rhs.nanoseconds)
    }

    public static func * <T: BinaryInteger>(lhs: T, rhs: TimeAmount) -> TimeAmount {
        return TimeAmount(Int64(lhs) * rhs.nanoseconds)
    }

    public static func * <T: BinaryInteger>(lhs: TimeAmount, rhs: T) -> TimeAmount {
        return TimeAmount(lhs.nanoseconds * Int64(rhs))
    }
}

/// Represents a point in time.
///
/// Stores the time in nanoseconds as returned by `DispatchTime.now().uptimeNanoseconds`
///
/// `NIODeadline` allow chaining multiple tasks with the same deadline without needing to
/// compute new timeouts for each step
///
/// ```
/// func doSomething(deadline: NIODeadline) -> EventLoopFuture<Void> {
///     return step1(deadline: deadline).then {
///         step2(deadline: deadline)
///     }
/// }
/// doSomething(deadline: .now() + .seconds(5))
/// ```
///
/// - note: `NIODeadline` should not be used to represent a time interval
public struct NIODeadline: Equatable, Hashable {
    @available(*, deprecated, message: "This typealias doesn't server any purpose, please use UInt64 directly.")
    public typealias Value = UInt64

    // This really should be an UInt63 but we model it as Int64 with >=0 assert
    private var _uptimeNanoseconds: Int64 {
        didSet {
            assert(self._uptimeNanoseconds >= 0)
        }
    }

    /// The nanoseconds since boot representation of the `NIODeadline`.
    public var uptimeNanoseconds: UInt64 {
        return .init(self._uptimeNanoseconds)
    }

    public static let distantPast = NIODeadline(0)
    public static let distantFuture = NIODeadline(.init(Int64.max))

    private init(_ nanoseconds: Int64) {
        precondition(nanoseconds >= 0)
        self._uptimeNanoseconds = nanoseconds
    }

    public static func now() -> NIODeadline {
        return NIODeadline.uptimeNanoseconds(DispatchTime.now().uptimeNanoseconds)
    }

    public static func uptimeNanoseconds(_ nanoseconds: UInt64) -> NIODeadline {
        return NIODeadline(Int64(min(UInt64(Int64.max), nanoseconds)))
    }
}

extension NIODeadline: Comparable {
    public static func < (lhs: NIODeadline, rhs: NIODeadline) -> Bool {
        return lhs.uptimeNanoseconds < rhs.uptimeNanoseconds
    }

    public static func > (lhs: NIODeadline, rhs: NIODeadline) -> Bool {
        return lhs.uptimeNanoseconds > rhs.uptimeNanoseconds
    }
}

extension NIODeadline: CustomStringConvertible {
    public var description: String {
        return self.uptimeNanoseconds.description
    }
}

extension NIODeadline {
    public static func - (lhs: NIODeadline, rhs: NIODeadline) -> TimeAmount {
        // This won't ever crash, NIODeadlines are guanteed to be within 0 ..< 2^63-1 nanoseconds so the result can
        // definitely be stored in a TimeAmount (which is an Int64).
        return .nanoseconds(Int64(lhs.uptimeNanoseconds) - Int64(rhs.uptimeNanoseconds))
    }

    public static func + (lhs: NIODeadline, rhs: TimeAmount) -> NIODeadline {
        let partial: Int64
        let overflow: Bool
        (partial, overflow) = Int64(lhs.uptimeNanoseconds).addingReportingOverflow(rhs.nanoseconds)
        if overflow {
            assert(rhs.nanoseconds > 0) // this certainly must have overflowed towards +infinity
            return NIODeadline.distantFuture
        }
        guard partial >= 0 else {
            return NIODeadline.uptimeNanoseconds(0)
        }
        return NIODeadline(partial)
    }

    public static func - (lhs: NIODeadline, rhs: TimeAmount) -> NIODeadline {
        if rhs.nanoseconds < 0 {
            // The addition won't crash because the worst that could happen is `UInt64(Int64.max) + UInt64(Int64.max)`
            // which fits into an UInt64 (and will then be capped to Int64.max == distantFuture by `uptimeNanoseconds`).
            return NIODeadline.uptimeNanoseconds(lhs.uptimeNanoseconds + rhs.nanoseconds.magnitude)
        } else if rhs.nanoseconds > lhs.uptimeNanoseconds {
            // Cap it at `0` because otherwise this would be negative.
            return NIODeadline.init(0)
        } else {
            // This will be positive but still fix in an Int64.
            let result = Int64(lhs.uptimeNanoseconds) - rhs.nanoseconds
            assert(result >= 0)
            return NIODeadline(result)
        }
    }
}

extension EventLoop {
    /// Submit `task` to be run on this `EventLoop`.
    ///
    /// The returned `EventLoopFuture` will be completed when `task` has finished running. It will be succeeded with
    /// `task`'s return value or failed if the execution of `task` threw an error.
    ///
    /// - parameters:
    ///     - task: The synchronous task to run. As everything that runs on the `EventLoop`, it must not block.
    /// - returns: An `EventLoopFuture` containing the result of `task`'s execution.
    public func submit<T>(_ task: @escaping () throws -> T) -> EventLoopFuture<T> {
        let promise: EventLoopPromise<T> = makePromise(file: #file, line: #line)

        self.execute {
            do {
                promise.succeed(try task())
            } catch let err {
                promise.fail(err)
            }
        }

        return promise.futureResult
    }

    /// Submit `task` to be run on this `EventLoop`.
    ///
    /// The returned `EventLoopFuture` will be completed when `task` has finished running. It will be identical to
    /// the `EventLoopFuture` returned by `task`.
    ///
    /// - parameters:
    ///     - task: The synchronous task to run. As everything that runs on the `EventLoop`, it must not block.
    /// - returns: An `EventLoopFuture` identical to the `EventLooopFuture` returned from `task`.
    public func flatSubmit<T>(_ task: @escaping () -> EventLoopFuture<T>) -> EventLoopFuture<T> {
        return submit(task).flatMap { $0 }
    }

    /// Creates and returns a new `EventLoopPromise` that will be notified using this `EventLoop` as execution `NIOThread`.
    public func makePromise<T>(of type: T.Type = T.self, file: StaticString = #file, line: UInt = #line) -> EventLoopPromise<T> {
        return EventLoopPromise<T>(eventLoop: self, file: file, line: line)
    }

    /// Creates and returns a new `EventLoopFuture` that is already marked as failed. Notifications will be done using this `EventLoop` as execution `NIOThread`.
    ///
    /// - parameters:
    ///     - error: the `Error` that is used by the `EventLoopFuture`.
    /// - returns: a failed `EventLoopFuture`.
    public func makeFailedFuture<T>(_ error: Error, file: StaticString = #file, line: UInt = #line) -> EventLoopFuture<T> {
        return EventLoopFuture<T>(eventLoop: self, error: error, file: file, line: line)
    }

    /// Creates and returns a new `EventLoopFuture` that is already marked as success. Notifications will be done using this `EventLoop` as execution `NIOThread`.
    ///
    /// - parameters:
    ///     - result: the value that is used by the `EventLoopFuture`.
    /// - returns: a succeeded `EventLoopFuture`.
    public func makeSucceededFuture<Success>(_ value: Success, file: StaticString = #file, line: UInt = #line) -> EventLoopFuture<Success> {
        return EventLoopFuture<Success>(eventLoop: self, value: value, file: file, line: line)
    }

    /// An `EventLoop` forms a singular `EventLoopGroup`, returning itself as the 'next' `EventLoop`.
    ///
    /// - returns: Itself, because an `EventLoop` forms a singular `EventLoopGroup`.
    public func next() -> EventLoop {
        return self
    }

    /// Close this `EventLoop`.
    public func close() throws {
        // Do nothing
    }

    /// Schedule a repeated task to be executed by the `EventLoop` with a fixed delay between the end and start of each
    /// task.
    ///
    /// - parameters:
    ///     - initialDelay: The delay after which the first task is executed.
    ///     - delay: The delay between the end of one task and the start of the next.
    ///     - promise: If non-nil, a promise to fulfill when the task is cancelled and all execution is complete.
    ///     - task: The closure that will be executed.
    /// - return: `RepeatedTask`
    @discardableResult
    public func scheduleRepeatedTask(initialDelay: TimeAmount, delay: TimeAmount, notifying promise: EventLoopPromise<Void>? = nil, _ task: @escaping (RepeatedTask) throws -> Void) -> RepeatedTask {
        let futureTask: (RepeatedTask) -> EventLoopFuture<Void> = { repeatedTask in
            do {
                try task(repeatedTask)
                return self.makeSucceededFuture(())
            } catch {
                return self.makeFailedFuture(error)
            }
        }
        return self.scheduleRepeatedAsyncTask(initialDelay: initialDelay, delay: delay, notifying: promise, futureTask)
    }

    /// Schedule a repeated asynchronous task to be executed by the `EventLoop` with a fixed delay between the end and
    /// start of each task.
    ///
    /// - note: The delay is measured from the completion of one run's returned future to the start of the execution of
    ///         the next run. For example: If you schedule a task once per second but your task takes two seconds to
    ///         complete, the time interval between two subsequent runs will actually be three seconds (2s run time plus
    ///         the 1s delay.)
    ///
    /// - parameters:
    ///     - initialDelay: The delay after which the first task is executed.
    ///     - delay: The delay between the end of one task and the start of the next.
    ///     - promise: If non-nil, a promise to fulfill when the task is cancelled and all execution is complete.
    ///     - task: The closure that will be executed.
    /// - return: `RepeatedTask`
    @discardableResult
    public func scheduleRepeatedAsyncTask(initialDelay: TimeAmount,
                                          delay: TimeAmount,
                                          notifying promise: EventLoopPromise<Void>? = nil,
                                          _ task: @escaping (RepeatedTask) -> EventLoopFuture<Void>) -> RepeatedTask {
        let repeated = RepeatedTask(interval: delay, eventLoop: self, cancellationPromise: promise, task: task)
        repeated.begin(in: initialDelay)
        return repeated
    }

    /// Returns an `EventLoopIterator` over this `EventLoop`.
    ///
    /// - returns: `EventLoopIterator`
    public func makeIterator() -> EventLoopIterator {
        return EventLoopIterator([self])
    }

    /// Checks that this call is run from the EventLoop. If this is called from within the EventLoop this function will
    /// have no effect, if called from outside the EventLoop it will crash the process with a trap if run in debug mode.
    /// In release mode this function never has any effect.
    ///
    /// - note: This is not a customization point so calls to this function can be fully optimized out in release mode.
    @inlinable
    public func assertInEventLoop(file: StaticString = #file, line: UInt = #line) {
        debugOnly {
            self.preconditionInEventLoop(file: file, line: line)
        }
    }

    /// Checks the necessary condition of currently running on the called `EventLoop` for making forward progress.
    public func preconditionInEventLoop(file: StaticString = #file, line: UInt = #line) {
        precondition(self.inEventLoop, file: file, line: line)
    }
}

/// Internal representation of a `Registration` to an `Selector`.
///
/// Whenever a `Selectable` is registered to a `Selector` a `Registration` is created internally that is also provided within the
/// `SelectorEvent` that is provided to the user when an event is ready to be consumed for a `Selectable`. As we need to have access to the `ServerSocketChannel`
/// and `SocketChannel` (to dispatch the events) we create our own `Registration` that holds a reference to these.
enum NIORegistration: Registration {
    case serverSocketChannel(ServerSocketChannel, SelectorEventSet)
    case socketChannel(SocketChannel, SelectorEventSet)
    case datagramChannel(DatagramChannel, SelectorEventSet)
    case pipeChannel(PipeChannel, PipeChannel.Direction, SelectorEventSet)

    /// The `SelectorEventSet` in which this `NIORegistration` is interested in.
    var interested: SelectorEventSet {
        set {
            switch self {
            case .serverSocketChannel(let c, _):
                self = .serverSocketChannel(c, newValue)
            case .socketChannel(let c, _):
                self = .socketChannel(c, newValue)
            case .datagramChannel(let c, _):
                self = .datagramChannel(c, newValue)
            case .pipeChannel(let c, let d, _):
                self = .pipeChannel(c, d, newValue)
            }
        }
        get {
            switch self {
            case .serverSocketChannel(_, let i):
                return i
            case .socketChannel(_, let i):
                return i
            case .datagramChannel(_, let i):
                return i
            case .pipeChannel(_, _, let i):
                return i
            }
        }
    }
}

/// Execute the given closure and ensure we release all auto pools if needed.
private func withAutoReleasePool<T>(_ execute: () throws -> T) rethrows -> T {
    #if os(Linux)
    return try execute()
    #else
    return try autoreleasepool {
        try execute()
    }
    #endif
}

/// The different state in the lifecycle of an `EventLoop`.
private enum EventLoopLifecycleState {
    /// `EventLoop` is open and so can process more work.
    case open
    /// `EventLoop` is currently in the process of closing.
    case closing
    /// `EventLoop` is closed.
    case closed
}

/// `EventLoop` implementation that uses a `Selector` to get notified once there is more I/O or tasks to process.
/// The whole processing of I/O and tasks is done by a `NIOThread` that is tied to the `SelectableEventLoop`. This `NIOThread`
/// is guaranteed to never change!
@usableFromInline
internal final class SelectableEventLoop: EventLoop {
    private let selector: NIO.Selector<NIORegistration>
    private let thread: NIOThread
    private var scheduledTasks = PriorityQueue<ScheduledTask>(ascending: true)
    private var tasksCopy = ContiguousArray<() -> Void>()

    private let tasksLock = Lock()
    private var lifecycleState: EventLoopLifecycleState = .open

    private let _iovecs: UnsafeMutablePointer<IOVector>
    private let _storageRefs: UnsafeMutablePointer<Unmanaged<AnyObject>>

    let iovecs: UnsafeMutableBufferPointer<IOVector>
    let storageRefs: UnsafeMutableBufferPointer<Unmanaged<AnyObject>>

    // Used for gathering UDP writes.
    private let _msgs: UnsafeMutablePointer<MMsgHdr>
    private let _addresses: UnsafeMutablePointer<sockaddr_storage>
    let msgs: UnsafeMutableBufferPointer<MMsgHdr>
    let addresses: UnsafeMutableBufferPointer<sockaddr_storage>

    /// Creates a new `SelectableEventLoop` instance that is tied to the given `pthread_t`.

    private let promiseCreationStoreLock = Lock()
    private var _promiseCreationStore: [ObjectIdentifier: (file: StaticString, line: UInt)] = [:]

    @usableFromInline
    internal func promiseCreationStoreAdd<T>(future: EventLoopFuture<T>, file: StaticString, line: UInt) {
        precondition(_isDebugAssertConfiguration())
        self.promiseCreationStoreLock.withLock {
            self._promiseCreationStore[ObjectIdentifier(future)] = (file: file, line: line)
        }
    }

    internal func promiseCreationStoreRemove<T>(future: EventLoopFuture<T>) -> (file: StaticString, line: UInt) {
        precondition(_isDebugAssertConfiguration())
        return self.promiseCreationStoreLock.withLock {
            self._promiseCreationStore.removeValue(forKey: ObjectIdentifier(future))!
        }
    }

    public init(thread: NIOThread) throws {
        self.selector = try NIO.Selector()
        self.thread = thread
        self._iovecs = UnsafeMutablePointer.allocate(capacity: Socket.writevLimitIOVectors)
        self._storageRefs = UnsafeMutablePointer.allocate(capacity: Socket.writevLimitIOVectors)
        self.iovecs = UnsafeMutableBufferPointer(start: self._iovecs, count: Socket.writevLimitIOVectors)
        self.storageRefs = UnsafeMutableBufferPointer(start: self._storageRefs, count: Socket.writevLimitIOVectors)
        self._msgs = UnsafeMutablePointer.allocate(capacity: Socket.writevLimitIOVectors)
        self._addresses = UnsafeMutablePointer.allocate(capacity: Socket.writevLimitIOVectors)
        self.msgs = UnsafeMutableBufferPointer(start: _msgs, count: Socket.writevLimitIOVectors)
        self.addresses = UnsafeMutableBufferPointer(start: _addresses, count: Socket.writevLimitIOVectors)
        // We will process 4096 tasks per while loop.
        self.tasksCopy.reserveCapacity(4096)
    }

    deinit {
        _iovecs.deallocate()
        _storageRefs.deallocate()
        _msgs.deallocate()
        _addresses.deallocate()
    }

    /// Is this `SelectableEventLoop` still open (ie. not shutting down or shut down)
    internal var isOpen: Bool {
        self.assertInEventLoop()
        return self.lifecycleState == .open
    }

    /// Register the given `SelectableChannel` with this `SelectableEventLoop`. After this point all I/O for the `SelectableChannel` will be processed by this `SelectableEventLoop` until it
    /// is deregistered by calling `deregister`.
    public func register<C: SelectableChannel>(channel: C) throws {
        self.assertInEventLoop()

        // Don't allow registration when we're closed.
        guard self.lifecycleState == .open else {
            throw EventLoopError.shutdown
        }

        try channel.register(selector: self.selector, interested: channel.interestedEvent)
    }

    /// Deregister the given `SelectableChannel` from this `SelectableEventLoop`.
    public func deregister<C: SelectableChannel>(channel: C, mode: CloseMode = .all) throws {
        self.assertInEventLoop()
        guard lifecycleState == .open else {
            // It's possible the EventLoop was closed before we were able to call deregister, so just return in this case as there is no harm.
            return
        }

        try channel.deregister(selector: self.selector, mode: mode)
    }

    /// Register the given `SelectableChannel` with this `SelectableEventLoop`. This should be done whenever `channel.interestedEvents` has changed and it should be taken into account when
    /// waiting for new I/O for the given `SelectableChannel`.
    public func reregister<C: SelectableChannel>(channel: C) throws {
        self.assertInEventLoop()

        try channel.reregister(selector: self.selector, interested: channel.interestedEvent)
    }

    /// - see: `EventLoop.inEventLoop`
    public var inEventLoop: Bool {
        return thread.isCurrent
    }

    /// - see: `EventLoop.scheduleTask(deadline:_:)`
    public func scheduleTask<T>(deadline: NIODeadline, _ task: @escaping () throws -> T) -> Scheduled<T> {
        let promise: EventLoopPromise<T> = makePromise()
        let task = ScheduledTask({
            do {
                promise.succeed(try task())
            } catch let err {
                promise.fail(err)
            }
        }, { error in
            promise.fail(error)
        }, deadline)

        let scheduled = Scheduled(promise: promise, cancellationTask: {
            self.tasksLock.withLockVoid {
                self.scheduledTasks.remove(task)
            }
            self.wakeupSelector()
        })

        schedule0(task)
        return scheduled
    }

    /// - see: `EventLoop.scheduleTask(in:_:)`
    public func scheduleTask<T>(in: TimeAmount, _ task: @escaping () throws -> T) -> Scheduled<T> {
        return scheduleTask(deadline: .now() + `in`, task)
    }

    // - see: `EventLoop.execute`
    public func execute(_ task: @escaping () -> Void) {
        schedule0(ScheduledTask(task, { error in
            // do nothing
        }, .now()))
    }

    /// Add the `ScheduledTask` to be executed.
    private func schedule0(_ task: ScheduledTask) {
        tasksLock.withLockVoid {
            scheduledTasks.push(task)
        }
        wakeupSelector()
    }

    /// Wake the `Selector` which means `Selector.whenReady(...)` will unblock.
    private func wakeupSelector() {
        do {
            try selector.wakeup()
        } catch let err {
            fatalError("Error during Selector.wakeup(): \(err)")
        }
    }

    /// Handle the given `SelectorEventSet` for the `SelectableChannel`.
    internal final func handleEvent<C: SelectableChannel>(_ ev: SelectorEventSet, channel: C) {
        guard channel.isOpen else {
            return
        }

        // process resets first as they'll just cause the writes to fail anyway.
        if ev.contains(.reset) {
            channel.reset()
        } else {
            if ev.contains(.writeEOF) {
                channel.writeEOF()

                guard channel.isOpen else {
                    return
                }
            } else if ev.contains(.write) {
                channel.writable()

                guard channel.isOpen else {
                    return
                }
            }

            if ev.contains(.readEOF) {
                channel.readEOF()
            } else if ev.contains(.read) {
                channel.readable()
            }
        }
    }

    private func currentSelectorStrategy(nextReadyTask: ScheduledTask?) -> SelectorStrategy {
        guard let sched = nextReadyTask else {
            // No tasks to handle so just block. If any tasks were added in the meantime wakeup(...) was called and so this
            // will directly unblock.
            return .block
        }

        let nextReady = sched.readyIn(.now())
        if nextReady <= .nanoseconds(0) {
            // Something is ready to be processed just do a non-blocking select of events.
            return .now
        } else {
            return .blockUntilTimeout(nextReady)
        }
    }

    /// Start processing I/O and tasks for this `SelectableEventLoop`. This method will continue running (and so block) until the `SelectableEventLoop` is closed.
    public func run() throws {
        self.preconditionInEventLoop()
        defer {
            var scheduledTasksCopy = ContiguousArray<ScheduledTask>()
            tasksLock.withLockVoid {
                // reserve the correct capacity so we don't need to realloc later on.
                scheduledTasksCopy.reserveCapacity(scheduledTasks.count)
                while let sched = scheduledTasks.pop() {
                    scheduledTasksCopy.append(sched)
                }
            }

            // Fail all the scheduled tasks.
            for task in scheduledTasksCopy {
                task.fail(EventLoopError.shutdown)
            }
        }
        var nextReadyTask: ScheduledTask? = nil
        while lifecycleState != .closed {
            // Block until there are events to handle or the selector was woken up
            /* for macOS: in case any calls we make to Foundation put objects into an autoreleasepool */
            try withAutoReleasePool {
                try selector.whenReady(strategy: currentSelectorStrategy(nextReadyTask: nextReadyTask)) { ev in
                    switch ev.registration {
                    case .serverSocketChannel(let chan, _):
                        self.handleEvent(ev.io, channel: chan)
                    case .socketChannel(let chan, _):
                        self.handleEvent(ev.io, channel: chan)
                    case .datagramChannel(let chan, _):
                        self.handleEvent(ev.io, channel: chan)
                    case .pipeChannel(let chan, let direction, _):
                        var ev = ev
                        if ev.io.contains(.reset) {
                            // .reset needs special treatment here because we're dealing with two separate pipes instead
                            // of one socket. So we turn .reset input .readEOF/.writeEOF.
                            ev.io.subtract([.reset])
                            ev.io.formUnion([direction == .input ? .readEOF : .writeEOF])
                        }
                        self.handleEvent(ev.io, channel: chan)
                    }
                }
            }

            // We need to ensure we process all tasks, even if a task added another task again
            while true {
                // TODO: Better locking
                tasksLock.withLockVoid {
                    if !scheduledTasks.isEmpty {
                        // We only fetch the time one time as this may be expensive and is generally good enough as if we miss anything we will just do a non-blocking select again anyway.
                        let now: NIODeadline = .now()

                        // Make a copy of the tasks so we can execute these while not holding the lock anymore
                        while tasksCopy.count < tasksCopy.capacity, let task = scheduledTasks.peek() {
                            if task.readyIn(now) <= .nanoseconds(0) {
                                scheduledTasks.pop()
                                tasksCopy.append(task.task)
                            } else {
                                nextReadyTask = task
                                break
                            }
                        }
                    } else {
                        // Reset nextReadyTask to nil which means we will do a blocking select.
                        nextReadyTask = nil
                    }
                }

                // all pending tasks are set to occur in the future, so we can stop looping.
                if tasksCopy.isEmpty {
                    break
                }

                // Execute all the tasks that were summited
                for task in tasksCopy {
                    /* for macOS: in case any calls we make to Foundation put objects into an autoreleasepool */
                    withAutoReleasePool {
                        task()
                    }
                }
                // Drop everything (but keep the capacity) so we can fill it again on the next iteration.
                tasksCopy.removeAll(keepingCapacity: true)
            }
        }

        // This EventLoop was closed so also close the underlying selector.
        try self.selector.close()
    }

    fileprivate func close0() throws {
        if inEventLoop {
            self.lifecycleState = .closed
        } else {
            self.execute {
                self.lifecycleState = .closed
            }
        }
    }

    /// Gently close this `SelectableEventLoop` which means we will close all `SelectableChannel`s before finally close this `SelectableEventLoop` as well.
    public func closeGently() -> EventLoopFuture<Void> {
        func closeGently0() -> EventLoopFuture<Void> {
            guard self.lifecycleState == .open else {
                return self.makeFailedFuture(EventLoopError.shutdown)
            }
            self.lifecycleState = .closing
            return self.selector.closeGently(eventLoop: self)
        }
        if self.inEventLoop {
            return closeGently0()
        } else {
            let p = self.makePromise(of: Void.self)
            self.execute {
                closeGently0().cascade(to: p)
            }
            return p.futureResult
        }
    }

    @usableFromInline
    func shutdownGracefully(queue: DispatchQueue, _ callback: @escaping (Error?) -> Void) {
        // This function is never called legally because the only possibly owner of an `SelectableEventLoop` is
        // `MultiThreadedEventLoopGroup` which calls `closeGently`.
        queue.async {
            callback(EventLoopError.unsupportedOperation)
        }
    }
}

extension SelectableEventLoop: CustomStringConvertible {
    @usableFromInline
    var description: String {
        return self.tasksLock.withLock {
            return "SelectableEventLoop { selector = \(self.selector), scheduledTasks = \(self.scheduledTasks.description) }"
        }
    }
}


/// Provides an endless stream of `EventLoop`s to use.
public protocol EventLoopGroup: class {
    /// Returns the next `EventLoop` to use.
    ///
    /// The algorithm that is used to select the next `EventLoop` is specific to each `EventLoopGroup`. A common choice
    /// is _round robin_.
    func next() -> EventLoop

    /// Shuts down the eventloop gracefully. This function is clearly an outlier in that it uses a completion
    /// callback instead of an EventLoopFuture. The reason for that is that NIO's EventLoopFutures will call back on an event loop.
    /// The virtue of this function is to shut the event loop down. To work around that we call back on a DispatchQueue
    /// instead.
    func shutdownGracefully(queue: DispatchQueue, _ callback: @escaping (Error?) -> Void)

    /// Returns an `EventLoopIterator` over the `EventLoop`s in this `EventLoopGroup`.
    ///
    /// - returns: `EventLoopIterator`
    func makeIterator() -> EventLoopIterator
}

extension EventLoopGroup {
    public func shutdownGracefully(_ callback: @escaping (Error?) -> Void) {
        self.shutdownGracefully(queue: .global(), callback)
    }

    public func syncShutdownGracefully() throws {
        if let eventLoop = MultiThreadedEventLoopGroup.currentEventLoop {
            preconditionFailure("""
            BUG DETECTED: syncShutdownGracefully() must not be called when on an EventLoop.
            Calling syncShutdownGracefully() on any EventLoop can lead to deadlocks.
            Current eventLoop: \(eventLoop)
            """)
        }
        let errorStorageLock = Lock()
        var errorStorage: Error? = nil
        let continuation = DispatchWorkItem {}
        self.shutdownGracefully { error in
            if let error = error {
                errorStorageLock.withLock {
                    errorStorage = error
                }
            }
            continuation.perform()
        }
        continuation.wait()
        try errorStorageLock.withLock {
            if let error = errorStorage {
                throw error
            }
        }
    }
}

private let nextEventLoopGroupID = Atomic(value: 0)

/// Called per `NIOThread` that is created for an EventLoop to do custom initialization of the `NIOThread` before the actual `EventLoop` is run on it.
typealias ThreadInitializer = (NIOThread) -> Void

/// An `EventLoopGroup` which will create multiple `EventLoop`s, each tied to its own `NIOThread`.
///
/// The effect of initializing a `MultiThreadedEventLoopGroup` is to spawn `numberOfThreads` fresh threads which will
/// all run their own `EventLoop`. Those threads will not be shut down until `shutdownGracefully` or
/// `syncShutdownGracefully` is called.
///
/// - note: It's good style to call `MultiThreadedEventLoopGroup.shutdownGracefully` or
///         `MultiThreadedEventLoopGroup.syncShutdownGracefully` when you no longer need this `EventLoopGroup`. In
///         many cases that is just before your program exits.
/// - warning: Unit tests often spawn one `MultiThreadedEventLoopGroup` per unit test to force isolation between the
///            tests. In those cases it's important to shut the `MultiThreadedEventLoopGroup` down at the end of the
///            test. A good place to start a `MultiThreadedEventLoopGroup` is the `setUp` method of your `XCTestCase`
///            subclass, a good place to shut it down is the `tearDown` method.
public final class MultiThreadedEventLoopGroup: EventLoopGroup {

    private enum RunState {
        case running
        case closing([(DispatchQueue, (Error?) -> Void)])
        case closed(Error?)
    }

    private static let threadSpecificEventLoop = ThreadSpecificVariable<SelectableEventLoop>()

    private let index = Atomic<Int>(value: 0)
    private let eventLoops: [SelectableEventLoop]
    private let shutdownLock: Lock = Lock()
    private var runState: RunState = .running

    private static func setupThreadAndEventLoop(name: String, initializer: @escaping ThreadInitializer)  -> SelectableEventLoop {
        let lock = Lock()
        /* the `loopUpAndRunningGroup` is done by the calling thread when the EventLoop has been created and was written to `_loop` */
        let loopUpAndRunningGroup = DispatchGroup()

        /* synchronised by `lock` */
        var _loop: SelectableEventLoop! = nil

        loopUpAndRunningGroup.enter()
        NIOThread.spawnAndRun(name: name) { t in
            initializer(t)

            do {
                /* we try! this as this must work (just setting up kqueue/epoll) or else there's not much we can do here */
                let l = try! SelectableEventLoop(thread: t)
                threadSpecificEventLoop.currentValue = l
                defer {
                    threadSpecificEventLoop.currentValue = nil
                }
                lock.withLock {
                    _loop = l
                }
                loopUpAndRunningGroup.leave()
                try l.run()
            } catch let err {
                fatalError("unexpected error while executing EventLoop \(err)")
            }
        }
        loopUpAndRunningGroup.wait()
        return lock.withLock { _loop }
    }

    /// Creates a `MultiThreadedEventLoopGroup` instance which uses `numberOfThreads`.
    ///
    /// - note: Don't forget to call `shutdownGracefully` or `syncShutdownGracefully` when you no longer need this
    ///         `EventLoopGroup`. If you forget to shut the `EventLoopGroup` down you will leak `numberOfThreads`
    ///         (kernel) threads which are costly resources. This is especially important in unit tests where one
    ///         `MultiThreadedEventLoopGroup` is started per test case.
    ///
    /// - arguments:
    ///     - numberOfThreads: The number of `Threads` to use.
    public convenience init(numberOfThreads: Int) {
        let initializers: [ThreadInitializer] = Array(repeating: { _ in }, count: numberOfThreads)
        self.init(threadInitializers: initializers)
    }
    
    /// Creates a `MultiThreadedEventLoopGroup` instance which uses the given `ThreadInitializer`s. One `NIOThread` per `ThreadInitializer` is created and used.
    ///
    /// - arguments:
    ///     - threadInitializers: The `ThreadInitializer`s to use.
    internal init(threadInitializers: [ThreadInitializer]) {
        let myGroupID = nextEventLoopGroupID.add(1)
        var idx = 0
        self.eventLoops = threadInitializers.map { initializer in
            // Maximum name length on linux is 16 by default.
            let ev = MultiThreadedEventLoopGroup.setupThreadAndEventLoop(name: "NIO-ELT-\(myGroupID)-#\(idx)",
                                                                         initializer: initializer)
            idx += 1
            return ev
        }
    }

    /// Returns the `EventLoop` for the calling thread.
    ///
    /// - returns: The current `EventLoop` for the calling thread or `nil` if none is assigned to the thread.
    public static var currentEventLoop: EventLoop? {
        return threadSpecificEventLoop.currentValue
    }

    /// Returns an `EventLoopIterator` over the `EventLoop`s in this `MultiThreadedEventLoopGroup`.
    ///
    /// - returns: `EventLoopIterator`
    public func makeIterator() -> EventLoopIterator {
        return EventLoopIterator(self.eventLoops)
    }

    /// Returns the next `EventLoop` from this `MultiThreadedEventLoopGroup`.
    ///
    /// `MultiThreadedEventLoopGroup` uses _round robin_ across all its `EventLoop`s to select the next one.
    ///
    /// - returns: The next `EventLoop` to use.
    public func next() -> EventLoop {
        return eventLoops[abs(index.add(1) % eventLoops.count)]
    }

    internal func unsafeClose() throws {
        for loop in eventLoops {
            // TODO: Should we log this somehow or just rethrow the first error ?
            try loop.close0()
        }
    }

    /// Shut this `MultiThreadedEventLoopGroup` down which causes the `EventLoop`s and their associated threads to be
    /// shut down and release their resources.
    ///
    /// Even though calling `shutdownGracefully` more than once should be avoided, it is safe to do so and execution
    /// of the `handler` is guaranteed.
    ///
    /// - parameters:
    ///    - queue: The `DispatchQueue` to run `handler` on when the shutdown operation completes.
    ///    - handler: The handler which is called after the shutdown operation completes. The parameter will be `nil`
    ///               on success and contain the `Error` otherwise.
    public func shutdownGracefully(queue: DispatchQueue, _ handler: @escaping (Error?) -> Void) {
        // This method cannot perform its final cleanup using EventLoopFutures, because it requires that all
        // our event loops still be alive, and they may not be. Instead, we use Dispatch to manage
        // our shutdown signaling, and then do our cleanup once the DispatchQueue is empty.
        let g = DispatchGroup()
        let q = DispatchQueue(label: "nio.shutdownGracefullyQueue", target: queue)
        let wasRunning: Bool = self.shutdownLock.withLock {
            // We need to check the current `runState` and react accordingly.
            switch self.runState {
            case .running:
                // If we are still running, we set the `runState` to `closing`,
                // so that potential future invocations know, that the shutdown
                // has already been initiaited.
                self.runState = .closing([])
                return true
            case .closing(var callbacks):
                // If we are currently closing, we need to register the `handler`
                // for invocation after the shutdown is completed.
                callbacks.append((q, handler))
                self.runState = .closing(callbacks)
                return false
            case .closed(let error):
                // If we are already closed, we can directly dispatch the `handler`
                q.async {
                    handler(error)
                }
                return false
            }
        }

        // If the `runState` was not `running` when `shutdownGracefully` was called,
        // the shutdown has already been initiated and we have to return here.
        guard wasRunning else {
            return
        }

        var error: Error? = nil

        for loop in self.eventLoops {
            g.enter()
            loop.closeGently().recover { err in
                q.sync { error = err }
            }.whenComplete { (_: Result<Void, Error>) in
                g.leave()
            }
        }

        g.notify(queue: q) {
            let failure = self.eventLoops.map { try? $0.close0() }.filter { $0 == nil }.count > 0

            // TODO: For Swift NIO 2.0 we should join in the threads used by the EventLoop before invoking the callback
            //       to ensure they're really gone (#581).
            if failure {
                error = EventLoopError.shutdownFailed
            }

            handler(error)

            let callbacks: [(DispatchQueue, (Error?) -> Void)] = self.shutdownLock.withLock {
                guard case .closing(let callbacks) = self.runState else {
                    fatalError("runState was \(self.runState), expected .closing")
                }

                self.runState = .closed(error)

                return callbacks
            }

            for (q, handler) in callbacks {
                q.async {
                    handler(error)
                }
            }
        }
    }
}

private final class ScheduledTask {
    let task: () -> Void
    private let failFn: (Error) ->()
    private let readyTime: NIODeadline

    init(_ task: @escaping () -> Void, _ failFn: @escaping (Error) -> Void, _ time: NIODeadline) {
        self.task = task
        self.failFn = failFn
        self.readyTime = time
    }

    func readyIn(_ t: NIODeadline) -> TimeAmount {
        if readyTime < t {
            return .nanoseconds(0)
        }
        return readyTime - t
    }

    func fail(_ error: Error) {
        failFn(error)
    }
}

extension ScheduledTask: CustomStringConvertible {
    var description: String {
        return "ScheduledTask(readyTime: \(self.readyTime))"
    }
}

extension ScheduledTask: Comparable {
    static func < (lhs: ScheduledTask, rhs: ScheduledTask) -> Bool {
        return lhs.readyTime < rhs.readyTime
    }

    static func == (lhs: ScheduledTask, rhs: ScheduledTask) -> Bool {
        return lhs === rhs
    }
}

/// Different `Error`s that are specific to `EventLoop` operations / implementations.
public enum EventLoopError: Error {
    /// An operation was executed that is not supported by the `EventLoop`
    case unsupportedOperation

    /// An scheduled task was cancelled.
    case cancelled

    /// The `EventLoop` was shutdown already.
    case shutdown

    /// Shutting down the `EventLoop` failed.
    case shutdownFailed
}
