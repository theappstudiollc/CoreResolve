//
//  CoreDataStack.swift
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

/// Represents a specific CoreData stack configuration
public protocol CoreDataStack {
	
	/// Returns a NSManagedObjectContext appropriate for the provided thread
	///
	/// - Parameter thread: The thread for which the context will be used
	/// - Returns: The NSManagedObjectContext for the provided thread
	func context(for thread: Thread) -> NSManagedObjectContext
}
