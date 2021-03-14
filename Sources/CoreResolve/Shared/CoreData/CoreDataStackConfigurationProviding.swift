//
//  CoreDataManagerConfigurationProviding.swift
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

/// Describes a CoreData persistent store type
///
/// - memory: Represents an in-memory store
/// - sqlite: Represents a sqlite store with a file store URL
public enum CoreDataStackPersistentStoreType {
	
	case memory
	
	case sqlite(fileStoreUrl: URL)
}

/// Protocol used by a CoreDataStack instance to configure a CoreData stack
public protocol CoreDataStackConfigurationProviding {
	
	/// Defines an array of configurations by name in a CoreData model
	var configurations: [String]? { get }
	
	/// Defines an array of URLs that the CoreDataMananger will manage
	var modelURLs: [URL] { get }
	
	/// Returns a dictionary of NSPersistentStore options
	///
	/// - Parameter configuration: The configuration as named in the `configurations` array
	/// - Returns: A dictionary of NSPersistentStore options
	func persistentStoreOptions(forConfiguration configuration: String?) -> [AnyHashable : Any]?
	
	/// Returns the CoreData persistent store type
	///
	/// - Parameter configuration: The configuration as named in the `configurations` array
	/// - Returns: The CoreDataManagerPersistentStoreType representing the persistent store type
	func persistentStoreType(forConfiguration configuration: String?) throws -> CoreDataStackPersistentStoreType
}

// MARK: - Extracts CoreData-specific values from the CoreDataStackPersistentStoreType
internal extension CoreDataStackConfigurationProviding {
	
	func coreDataStoreType(forConfiguration configuration: String?) throws -> String {
		switch try persistentStoreType(forConfiguration: configuration) {
		case .memory:
			return NSInMemoryStoreType
		case .sqlite(_):
			return NSSQLiteStoreType
		}
	}
	
	func persistentStoreUrl(forConfiguration configuration: String?) throws -> URL? {
		switch try persistentStoreType(forConfiguration: configuration) {
		case .memory:
			return nil
		case .sqlite(let fileStoreUrl):
			return fileStoreUrl
		}
	}
}
