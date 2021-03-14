//
//  MultiCoordinatorSynchronouslyMergingCoreDataStack.swift
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

open class MultiCoordinatorSynchronouslyMergingCoreDataStack: SynchronouslyMergingCoreDataStack {
	
	var backgroundCoordinator: NSPersistentStoreCoordinator!
	
	/// Initializes a new instance of the CoreDataStack
	///
	/// - Parameters:
	///   - configurationProvider: The CoreDataManagerConfigurationProviding instance that will configure the manager
	///   - backgroundContextPoolSize: The number of background NSManagedObjectContexts to maintain in a pool
	///   - notificationCenter: The NotificationCenter object to use to listen to events
	///   - operationQueue: An optional OperationQueue for use with the NSManagedObjectContextDidSave notification
	public override init(configurationProvider: CoreDataStackConfigurationProviding, backgroundContextPoolSize: UInt = 1, notificationCenter: NotificationCenter = .default, operationQueue: OperationQueue? = nil) throws {
		try super.init(configurationProvider: configurationProvider, backgroundContextPoolSize: backgroundContextPoolSize, notificationCenter: notificationCenter, operationQueue: operationQueue)
		backgroundCoordinator = try createCoordinator()
	}
	
	open override func createContext(with concurrencyType: NSManagedObjectContextConcurrencyType) -> NSManagedObjectContext {
		let retVal = NSManagedObjectContext(concurrencyType: concurrencyType)
		switch concurrencyType {
		case .mainQueueConcurrencyType:
			retVal.persistentStoreCoordinator = mainCoordinator
		default:
			retVal.persistentStoreCoordinator = backgroundCoordinator
		}
		return retVal
	}
}
