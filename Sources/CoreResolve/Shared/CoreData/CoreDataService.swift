//
//  CoreDataService.swift
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

/// Protocol representing controlled access to a CoreData stack
public protocol CoreDataService {
	
	/// Uses NSManagedObjectContext's performBlock call, which includes a built-in autorelease pool and a call to processPendingChanges. Unless you are calling from the main thread, you cannot access any resulting NSManagedObjects and their properties outside of the closure
	///
	/// - Parameter closure: The closure to execute
	func perform(_ closure: @escaping (NSManagedObjectContext) -> Void)
	
	/// Uses NSManagedObjectContext's performBlockAndWait call. Client code may wish to use an autorelease pool inside the block
	///
	/// - Parameter closure: The closure to execute
	func performAndWait(_ closure: (NSManagedObjectContext) -> Void)
	
	/// A singular context for use with Views only
	var viewContext: NSManagedObjectContext { get }
}

// MARK: - Generics methods for interacting with CoreDataService
public extension CoreDataService {
	
	/// Uses performAndWait call on the supplied closure and returns the result
	///
	/// - Parameter closure: The closure to execute
	/// - Returns: Returns the T value returned by the closure
	/// - Throws: Rethrows any error thrown inside the closure
	func performAndReturn<T>(_ closure: (NSManagedObjectContext) throws -> T) rethrows -> T {
		var result: Result<T, Error>!
		performAndWait { context in
			do {
				result = .success(try closure(context))
			} catch {
				result = .failure(error)
			}
		}
		switch result! {
		case .success(let value):
			return value
		case .failure(let error):
			// declare a function that meets `rethrow` rules and execute it, guaranteeing a throw
			func rethrow(error: Error) throws -> T { throw error }
			return try rethrow(error: error)
		}
	}
}
