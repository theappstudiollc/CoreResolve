//
//  BasicSQLiteCoreDataStackConfigurationProvider.swift
//  CoreResolve
//
//  Created by David Mitchell
//  Copyright © 2019 The App Studio LLC.
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

/// Provides a basic (single configuration) CoreData configuration for a SQLite-backed data store
open class BasicSQLiteCoreDataStackConfigurationProvider: CoreDataStackConfigurationProviding {

	// MARK: - Public properties and methods
	
	/// The `CoreFileStoreService` passed in during initialization
	public let fileStoreService: CoreFileStoreService
	
	/// The name of the configuration in the model that this provider represents, or `nil` if the default configuration is desired
	public let configurationName: String?
	
	/// The `CoreFileStoreDirectoryType` that will be the directory for the data store
	public let dataStoreDirectoryType: CoreFileStoreDirectoryType
	
	/// The file name of the data store file (minus extension)
	public let dataStoreFileName: String

	/// The bundle containing the .momd resource
	public let resourceBundle: Bundle
	
	/// The name of the .momd resource in the bundle
	public let resourceName: String

	/// Initializes a new instance of the configuration provider
	///
	/// - Parameter fileStoreService: A `CoreFileStoreService` to use for creating the database files
	/// - Parameter resourceName: The name of the .momd resource in the bundle
	/// - Parameter resourceBundle: The bundle containing the .momd resource
	/// - Parameter configurationName: The name of the configuration in the model that this provider represents, or `nil` if the default configuration is desired
	/// - Parameter dataStoreDirectoryType: The `CoreFileStoreDirectoryType` that will be the directory for the data store
	/// - Parameter dataStoreFileName: The file name of the data store file (minus the extension)
	public init(fileStoreService: CoreFileStoreService, resourceName: String, resourceBundle: Bundle, configurationName: String? = nil, dataStoreDirectoryType: CoreFileStoreDirectoryType, dataStoreFileName: String) throws {
		try fileStoreService.ensureDirectoryExists(for: dataStoreDirectoryType)
		self.configurationName = configurationName
		self.dataStoreDirectoryType = dataStoreDirectoryType
		self.dataStoreFileName = dataStoreFileName
		self.fileStoreService = fileStoreService
		self.resourceBundle = resourceBundle
		self.resourceName = resourceName
	}
	
	// MARK: - CoreDataServiceConfigurationProviding
	
	/// The array of configurations by name in our CoreData model
	open var configurations: [String]? {
		guard let configurationName = configurationName else {
			return nil
		}
		return [configurationName]
	}
	
	/// The array of URLs that the CoreDataMananger will manage
	open var modelURLs: [URL] {
		return [resourceBundle.url(forResource: resourceName, withExtension: "momd")!]
	}
	
	/// Returns a dictionary of NSPersistentStore options
	///
	/// - Parameter configuration: The configuration as named in the `configurations` array
	/// - Returns: A dictionary of NSPersistentStore options
	open func persistentStoreOptions(forConfiguration configuration: String?) -> [AnyHashable : Any]? {
		guard configuration == nil || configuration! == configurationName else { return nil }
		return [NSMigratePersistentStoresAutomaticallyOption: true,
				NSInferMappingModelAutomaticallyOption: true]
	}
	
	/// Returns the CoreData persistent store type
	///
	/// - Parameter configuration: The configuration as named in the `configurations` array
	/// - Returns: The CoreDataManagerPersistentStoreType representing the persistent store type
	open func persistentStoreType(forConfiguration configuration: String?) throws -> CoreDataStackPersistentStoreType {
		if configuration == nil || configuration! == configurationName {
			let applicationDataUrl = try fileStoreService.directoryUrl(for: dataStoreDirectoryType)
			let dataStoreUrl = URL(fileURLWithPath: "\(dataStoreFileName).sqlite", relativeTo: applicationDataUrl)
			return .sqlite(fileStoreUrl: dataStoreUrl)
		}
		throw CoreDataStackError.invalidConfigurationName
	}
}
