//
//  SynchronouslyMergingCoreDataStack.swift
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
import CoreResolve_ObjC

open class SynchronouslyMergingCoreDataStack: MultiContextCoreDataStack {
	
	/// Initializes a new instance of the CoreDataStack
	///
	/// - Parameters:
	///   - configurationProvider: The CoreDataManagerConfigurationProviding instance that will configure the manager
	///   - backgroundContextPoolSize: The number of background NSManagedObjectContexts to maintain in a pool
	///   - notificationCenter: The NotificationCenter object to use to listen to events
	///   - operationQueue: An optional OperationQueue for use with the NSManagedObjectContextDidSave notification
	public override init(configurationProvider: CoreDataStackConfigurationProviding, backgroundContextPoolSize: UInt = 1, notificationCenter: NotificationCenter = .default, operationQueue: OperationQueue? = nil) throws {
		try super.init(configurationProvider: configurationProvider, backgroundContextPoolSize: backgroundContextPoolSize, notificationCenter: notificationCenter, operationQueue: operationQueue)
	}
	
	override func mergeSavedChanges(from notification: Notification, into otherContexts: [NSManagedObjectContext]) {
		for context in otherContexts {
			// We don't know what state other contexts are in, so we perform rather than performAndWait to avoid deadlocks
			context.perform {
				if #available(iOS 10.0, tvOS 10.0, *) {
					context.mergeChanges(fromContextDidSave: notification)
				} else {
					if let updatedObjects = notification.userInfo![NSUpdatedObjectsKey] as? [NSManagedObject] {
						// Fixes problem with NSFetchedResultsController on iOS 9.x and below
						for updatedObject in updatedObjects {
							do {
								try CRKObjectiveC.catchExceptionAndThrow {
									let contextObject = context.object(with: updatedObject.objectID)
									contextObject.willAccessValue(forKey: nil)
								}
							} catch {
								// TODO: We should use a logger
							}
						}
					}
					context.mergeChanges(fromContextDidSave: notification)
				}
			}
		}
	}
}
