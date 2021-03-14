//
//  FetchedResultsControllerDataSource.swift
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

/// Implements a generic NSFetchedResultsControllerDelegate
@available(iOS 3.0, macOS 10.12, tvOS 9.0, *)
open class FetchedResultsControllerDataSource<ResultType>: NSObject, NSFetchedResultsControllerDelegate where ResultType: NSFetchRequestResult {

	public typealias FetchController = () throws -> NSFetchedResultsController<ResultType>
	
	public var fetchedResultsController: NSFetchedResultsController<ResultType> {
		guard _fetchedResultsController == nil else { return _fetchedResultsController! }
		do {
			_fetchedResultsController = try fetchController()
			try _fetchedResultsController!.performFetch()
		} catch {
			handleFetchError(error, _fetchedResultsController)
		}
		return _fetchedResultsController!
	}
	
	public init(with fetchController: @escaping FetchController) {
		self.fetchController = fetchController
		super.init()
	}
	
	open func handleFetchError(_ error: Error, _ fetchedResultsController: NSFetchedResultsController<ResultType>?) {
		fatalError("\(self): Unhandled error loading new NSFetchedResultsController: \(error.localizedDescription)")
	}
	
	override open func responds(to aSelector: Selector!) -> Bool {
		guard !Self.tracksResults else {
			return super.responds(to: aSelector)
		}
		switch aSelector {
		case #selector(NSFetchedResultsControllerDelegate.controllerDidChangeContent(_:)),
			 #selector(NSFetchedResultsControllerDelegate.controller(_:didChange:at:for:newIndexPath:)),
			 #selector(NSFetchedResultsControllerDelegate.controller(_:didChange:atSectionIndex:for:)),
			 #selector(NSFetchedResultsControllerDelegate.controllerWillChangeContent(_:)):
			return false
		default:
			return super.responds(to: aSelector)
		}
	}
	
	public func setNeedsReload() {
		_fetchedResultsController = nil
	}
	
	open class var tracksResults: Bool {
		return false
	}
	
	internal var _fetchedResultsController: NSFetchedResultsController<ResultType>? = nil {
		didSet { _fetchedResultsController?.delegate = self }
	}
	internal let fetchController: FetchController
	
	// MARK: - NSFetchedResultsControllerDelegate methods
	
	open func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) { }
	
	public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) { }
	
	public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) { }
	
	open func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) { }
	
//	open func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, sectionIndexTitleForSectionName sectionName: String) -> String? { }
}

// MARK: - Support for UIDataSourceModelAssociation in subclasses

@available(iOS 3.0, macOS 10.12, tvOS 9.0, *)
extension FetchedResultsControllerDataSource where ResultType: NSManagedObject {
	
	public func objectURI(forElementAt indexPath: IndexPath) -> URL? {
		let object = fetchedResultsController.object(at: indexPath)
		return object.objectID.isTemporaryID ? nil : object.objectID.uriRepresentation()
	}
	
	public func indexPath(forObjectURI url: URL) -> IndexPath? {
		let context = fetchedResultsController.managedObjectContext
		guard let objectID = context.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: url) else { return nil }
		let object = context.object(with: objectID)
		return fetchedResultsController.indexPath(forObject: object as! ResultType)
	}
}

@available(iOS 3.0, macOS 10.12, tvOS 9.0, *)
extension FetchedResultsControllerDataSource where ResultType: NSManagedObjectID {
	
	public func objectURI(forElementAt indexPath: IndexPath) -> URL? {
		let objectID = fetchedResultsController.object(at: indexPath)
		return objectID.isTemporaryID ? nil : objectID.uriRepresentation()
	}
	
	public func indexPath(forObjectURI url: URL) -> IndexPath? {
		let context = fetchedResultsController.managedObjectContext
		guard let objectID = context.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: url) else { return nil }
		return fetchedResultsController.indexPath(forObject: objectID as! ResultType)
	}
}
