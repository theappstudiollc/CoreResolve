//
//  CoreAsynchronousOperation.swift
//  CoreResolve
//
//  Created by David Mitchell
//  Copyright © 2018 The App Studio LLC.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//	   http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
//  Adapted from https://stackoverflow.com/a/48104095 (but also fixing a cancellation bug)

import Foundation

/// Protocol providing linking capabilities from one operation to another (via extensions)
public protocol CoreAsynchronousOperationLinking { }

/// Operation subclass that is explicitly asynchronous and supports operation bridging
open class CoreAsynchronousOperation: Operation, CoreAsynchronousOperationLinking {
	
	// MARK: - Public methods

	/// Call sometime after `main` to complete the operation. All paths, including cancellation, must lead to finish, otherwise the operation will forever consume its operation queue. This class' implementation of `start` already calls `finish` if the operation is cancelled before it begins
	open func finish() {
		queue.sync(flags: .barrier) {
			finishClosures?.forEach({ $0(self) })
			finishClosures?.removeAll()
		}
		state = .finished
	}
	
	// MARK: - Operation overrides
	
	public final override var isExecuting: Bool {
		return state == .executing
	}
	
	public final override var isFinished: Bool {
		return state == .finished
	}
	
	open override var isReady: Bool {
		return state == .ready && super.isReady
	}
	
	// Make sure KVO recognizes that `isReady`, `isFinished`, and `isExecuting` are affected by changes to `state`
	open override class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String> {
		if ["isReady", "isFinished", "isExecuting"].contains(key) {
			return ["state"]
		}
		return super.keyPathsForValuesAffectingValue(forKey: key)
	}
	
	/// Subclasses must implement this to perform their work, which must eventually lead to `finish()`. Do not call `super` as it invokes a fatalError
	open override func main() {
		fatalError("\(self) must override `main` and not call super.main().")
	}
	
	public final override func start() {
		if isCancelled {
			finish()
			return
		}
		state = .executing
		main()
	}
	
	// MARK: - Private and internal properties and methods
	
	/// State for this operation.
	@objc private enum State: Int {
		case ready
		case executing
		case finished
	}
	
	/// Defines the closure stored by finishClosures
	internal typealias FinishClosure = (_ operation: CoreAsynchronousOperation) -> Void
	
	/// Stores all of the FinishClosures
	internal var finishClosures: [FinishClosure]?
	
	/// Concurrent queue for synchronizing access to `state` and `finishClosures`
	fileprivate let queue = DispatchQueue(label: "\(type(of: self)).queue", attributes: .concurrent)
	
	/// Private backing store for `state`
	private var _state: State = .ready
	
	/// The state of the operation
	@objc private dynamic var state: State {
		get { return queue.sync { _state } }
		set { queue.sync(flags: .barrier) { _state = newValue } }
	}
}

// MARK: - Linking support

public extension CoreAsynchronousOperationLinking where Self: CoreAsynchronousOperation {
	
	///  Adds a closure that will be performed at the end of `finish()`
	///
	/// - Parameter finishClosure: The closure to perform at the end of `finish()`
	func addFinishClosure(_ finishClosure: @escaping (Self) -> Void) {
		queue.sync(flags: .barrier) {
			if finishClosures == nil {
				finishClosures = []
			}
			finishClosures!.append {
				finishClosure($0 as! Self)
			}
		}
	}
	
	/// Sets up a dependency so that the provided operation waits for this one to finish, with a closure to execute in between, regardless whether the source operation is cancelled
	///
	/// - Parameters:
	///   - operation: The operation to wait for this one to finish
	///   - closure: A closure to execute after this one finishes but before the `operation` begins
	func link<T>(to operation: T, performing closure: @escaping (Self, T) -> Void) where T: Operation {
		operation.addDependency(self)
		addFinishClosure { source in
			closure(source, operation)
		}
	}
}
