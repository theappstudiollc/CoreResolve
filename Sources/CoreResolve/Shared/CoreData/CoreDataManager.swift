//
//  CoreDataManager.swift
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

import CoreData

/// Manages a CoreData stack
open class CoreDataManager {

	// MARK: - Public methods
	
	/// Initializes a new instance of the CoreDataManager
	///
	/// - Parameter stack: The CoreDataStack instance that will support the manager
	public init(stack: CoreDataStack) {
		self.stack = stack
	}
	
	// MARK: - Private properties
	
	fileprivate let stack: CoreDataStack
}

extension CoreDataManager: CoreDataService {
	
	/// Uses NSManagedObjectContext's performBlock call, which includes a built-in autorelease pool and a call to processPendingChanges. Unless you are calling from the main thread, you cannot access any resulting NSManagedObjects and their properties outside of the closure
	///
	/// - Parameter closure: The closure to execute
	public func perform(_ closure: @escaping (NSManagedObjectContext) -> Void) {
		let context = stack.context(for: .current)
		context.perform {
			let existingUndoManager = context.undoManager
			closure(context)
			context.undoManager = existingUndoManager
		}
	}
	
	/// Uses NSManagedObjectContext's performBlockAndWait call. Client code may wish to use an autorelease pool inside the block
	///
	/// - Parameter closure: The closure to execute
	public func performAndWait(_ closure: (NSManagedObjectContext) -> Void) {
		let context = stack.context(for: .current)
		context.performAndWait {
			let existingUndoManager = context.undoManager
			closure(context)
			context.undoManager = existingUndoManager
		}
	}
	
	/// A singular context for use with Views only
	public var viewContext: NSManagedObjectContext {
		return stack.context(for: .main)
	}
}
