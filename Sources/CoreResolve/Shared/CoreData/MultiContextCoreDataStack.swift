//
//  MultiContextCoreDataStack.swift
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

/// Base implementation of CoreDataStack that support a main-thread NSManagedObjectContext and 0 or more background-thread NSManagedObjectContexts
open class MultiContextCoreDataStack {
	
	let configurationProvider: CoreDataStackConfigurationProviding
	private var contextDidSaveObserver: NSObjectProtocol!
	private var contextPool: CoreDataContextPool
	private let contextThreadDictionaryKey = "\(MultiContextCoreDataStack.self).coreDataContext"
	internal weak var mainContext: NSManagedObjectContext?
	internal var mainCoordinator: NSPersistentStoreCoordinator!
	private let notificationCenter: NotificationCenter
	private var model: NSManagedObjectModel!
	private let syncQueue = DispatchQueue(label: "\(MultiContextCoreDataStack.self).queue")
	
	deinit {
		Thread.main.threadDictionary[contextThreadDictionaryKey] = nil
		notificationCenter.removeObserver(contextDidSaveObserver as Any)
	}
	
	/// Initializes a new instance of the CoreDataStack
	///
	/// - Parameters:
	///   - configurationProvider: The CoreDataManagerConfigurationProviding instance that will configure the manager
	///   - backgroundContextPoolSize: The number of background NSManagedObjectContexts to maintain in a pool
	///   - notificationCenter: The NotificationCenter object to use to listen to events
	///   - operationQueue: An optional OperationQueue for use with the NSManagedObjectContextDidSave notification
	public init(configurationProvider: CoreDataStackConfigurationProviding, backgroundContextPoolSize: UInt, notificationCenter: NotificationCenter, operationQueue: OperationQueue? = nil) throws {
		self.configurationProvider = configurationProvider
		self.notificationCenter = notificationCenter
		contextPool = CoreDataContextPool(poolSize: backgroundContextPoolSize)
		contextDidSaveObserver = notificationCenter.addObserver(forName: .NSManagedObjectContextDidSave, object: nil, queue: operationQueue) { notification in
			guard let notifyingContext = notification.object as? NSManagedObjectContext, self.isMemberContext(notifyingContext) else {
				return
			}
			let otherContexts = self.contexts(except: notifyingContext)
			self.mergeSavedChanges(from: notification, into: otherContexts)
		}
		model = try createModel()
		mainCoordinator = try createCoordinator()
	}
	
	private func contexts(except notifyingContext: NSManagedObjectContext) -> [NSManagedObjectContext] {
		var allContexts = [NSManagedObjectContext]()
		allContexts.reserveCapacity(contextPool.size + 1) // + main
		if let mainContext = self.mainContext {
			allContexts.append(mainContext)
		}
		allContexts.append(contentsOf: contextPool.contexts())
		return allContexts.filter { $0 != notifyingContext }
	}
	
	open func createContext(with concurrencyType: NSManagedObjectContextConcurrencyType) -> NSManagedObjectContext {
		fatalError("Subclasses must implement this method")
	}
	
	internal func createCoordinator() throws -> NSPersistentStoreCoordinator {
		let retVal = NSPersistentStoreCoordinator(managedObjectModel: model)
		if let configurations = configurationProvider.configurations {
			for configuration in configurations {
				try process(configuration: configuration, for: retVal)
			}
		} else {
			try process(configuration: nil, for: retVal)
		}
		return retVal
	}
	
	private func createModel() throws -> NSManagedObjectModel {
		let models = configurationProvider.modelURLs.map { modelURL in
			NSManagedObjectModel(contentsOf: modelURL)!
		}
		if models.count == 1 {
			return models.first!
		} else {
			return NSManagedObjectModel(byMerging: models)!
		}
	}
	
	private func isMemberContext(_ notifyingContext: NSManagedObjectContext) -> Bool {
		return notifyingContext == self.mainContext || contextPool.contexts().contains(notifyingContext)
	}
	
	internal func mergeSavedChanges(from notification: Notification, into otherContexts: [NSManagedObjectContext]) {
		fatalError("Subclasses must implement this method")
	}
	
	private func process(configuration: String?, for coordinator: NSPersistentStoreCoordinator) throws {
		let storeType = try configurationProvider.coreDataStoreType(forConfiguration: configuration)
		let storeURL = try configurationProvider.persistentStoreUrl(forConfiguration: configuration)
		let options = configurationProvider.persistentStoreOptions(forConfiguration: configuration)
		do {
			try coordinator.addPersistentStore(ofType: storeType, configurationName: configuration, at: storeURL, options: options)
		} catch {
			if let storeURL = storeURL {
				try coordinator.destroyPersistentStore(at: storeURL, ofType: storeType, options: options)
				try coordinator.addPersistentStore(ofType: storeType, configurationName: configuration, at: storeURL, options: options)
			} else {
				throw error
			}
		}
	}
}

extension MultiContextCoreDataStack: CoreDataStack {
	
	public func context(for thread: Thread) -> NSManagedObjectContext {
		let concurrencyType: NSManagedObjectContextConcurrencyType = thread.isMainThread ? .mainQueueConcurrencyType : .privateQueueConcurrencyType
		if let existingContext = thread.threadDictionary[contextThreadDictionaryKey] as? NSManagedObjectContext {
			return existingContext
		}
		var retVal: NSManagedObjectContext! = nil
		syncQueue.sync(flags: .barrier) {
			if concurrencyType == .mainQueueConcurrencyType || contextPool.size <= 0 {
				if mainContext == nil {
					retVal = createContext(with: .mainQueueConcurrencyType)
					mainContext = retVal
				} else {
					retVal = createContext(with: .mainQueueConcurrencyType)
				}
			} else {
				retVal = contextPool.next { createContext(with: concurrencyType) }
			}
			thread.threadDictionary[contextThreadDictionaryKey] = retVal
		}
		return retVal
	}
}
