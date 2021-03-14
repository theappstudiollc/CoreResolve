//
//  SingleCoordinatorAsynchronouslyMergingCoreDataStack.swift
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

@available(iOS 9.0, macOS 10.11, tvOS 9.0, *)
open class SingleCoordinatorAsynchronouslyMergingCoreDataStack: MultiContextCoreDataStack {
	
	/// Initializes a new instance of the CoreDataStack
	///
	/// - Parameters:
	///   - configurationProvider: The CoreDataManagerConfigurationProviding instance that will configure the manager
	///   - backgroundContextPoolSize: The number of background NSManagedObjectContexts to maintain in a pool
	///   - notificationCenter: The NotificationCenter object to use to listen to events
	///   - operationQueue: An optional OperationQueue for use with the NSManagedObjectContextDidSave notification
	///   - asyncMergeQueue: An optional DispatchQueue for use with NSManagedObjectContext.mergeChanges(fromRemoteContextSave:into:)
	public init(configurationProvider: CoreDataStackConfigurationProviding, backgroundContextPoolSize: UInt = 1, notificationCenter: NotificationCenter = .default, operationQueue: OperationQueue? = nil, asyncMergeQueue: DispatchQueue = .global()) throws {
		self.asyncMergeQueue = asyncMergeQueue
		try super.init(configurationProvider: configurationProvider, backgroundContextPoolSize: backgroundContextPoolSize, notificationCenter: notificationCenter, operationQueue: operationQueue)
	}

	open override func createContext(with concurrencyType: NSManagedObjectContextConcurrencyType) -> NSManagedObjectContext {
		let retVal = NSManagedObjectContext(concurrencyType: concurrencyType)
		retVal.persistentStoreCoordinator = mainCoordinator
		return retVal
	}
	
	override func mergeSavedChanges(from notification: Notification, into otherContexts: [NSManagedObjectContext]) {
		guard let saveInfo = notification.userInfo else {
			return
		}
		guard otherContexts.count > 0 else { return }
		asyncMergeQueue.async {
			NSManagedObjectContext.mergeChanges(fromRemoteContextSave: saveInfo, into: otherContexts)
		}
	}
	
	// MARK: - Private properties
	
	private let asyncMergeQueue: DispatchQueue
}
