//
//  FetchedResultsControllerPrefetchDataSource.swift
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

/// Represents an NSFetchRequestResult that can be represented in NSPredicates that use SELF in their expressions
public protocol CoreFetchRequestManagedObjectResult: NSFetchRequestResult { }

/// Adds `CoreFetchRequestManagedObjectResult` support to `NSManagedObject` because it may be used in NSPredicates with SELF expressions
extension NSManagedObject: CoreFetchRequestManagedObjectResult { }

/// Adds `CoreFetchRequestManagedObjectResult` support to `NSManagedObjectID` because it may be used in NSPredicates with SELF expressions
extension NSManagedObjectID: CoreFetchRequestManagedObjectResult { }

@available(iOS 10.0, macOS 10.13.0, tvOS 10.0, *)
/// Implements a basic `PrefetchDataSource` for ResultTypes based on a CoreData entity
open class FetchedResultsControllerPrefetchDataSource<ResultType>: PrefetchDataSource where ResultType: CoreFetchRequestManagedObjectResult {

	public let loggingService: CoreLoggingService
	private var pendingPrefetchResults = [[IndexPath] : NSPersistentStoreAsynchronousResult]()

	public init(loggingService: CoreLoggingService) {
		self.loggingService = loggingService
	}

	// MARK: - Overridable methods

	/// Returns a fetch request for prefetching based on the provided results and fetch request. The default behavior simply resolves any faults in any ResultType, if they exist
	/// - Parameters:
	///   - results: The results for which to attempt prefetching
	///   - fetchRequest: The fetch request used in fetching
	open func fetchRequestForPrefetching(results: [ResultType], from fetchRequest: NSFetchRequest<ResultType>) -> NSFetchRequest<NSFetchRequestResult>? {
		// Keep filtering to find out which results need prefetching
		guard fetchRequest.returnsObjectsAsFaults == true else {
			loggingService.log(.info, "no need to prefetch, default fetch request result types do not return faults")
			return nil
		}
		guard let entityName = fetchRequest.entityName else {
			loggingService.log(.info, "entity name cannot be found -- this is surprising")
			return nil
		}
		let filteredResult: [NSFetchRequestResult] = results.compactMap { result in
			guard let managedObject = result as? NSManagedObject else { return result }
			return managedObject.isFault ? managedObject : nil
		}
		guard filteredResult.count > 0 else {
//			loggingService.log(.debug, "Nothing to prefetch -- all %ld objects not faulted", results.count)
			return nil
		}
		// Simply fetch each of the remaining results to resolve any faults
		let result = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
		result.predicate = NSPredicate(format: "SELF IN %@", filteredResult)
		result.returnsObjectsAsFaults = false
		return result
	}

	/// Handles any error in prefetching. The default implementation brings down the app with a fatalError
	/// - Parameter error: The error encountered during prefetching
	open func handlePrefetchError(_ error: Error) {
		fatalError("\(self): Unhandled error during execute() \(error.localizedDescription)")
	}

	/// Optionally processes any of the prefetch results, if desired. The default implementation does nothing
	/// - Parameter results: The prefetched results
	open func processPrefetchResults(_ results: [NSFetchRequestResult]) { }

	// MARK: - PrefetchDataSource methods

	public func cancelPrefetching(indexPaths: [IndexPath]) {
		guard let result = pendingPrefetchResults.removeValue(forKey: indexPaths) else { return }
		result.cancel()
		loggingService.log(.info, "Cancelling prefetch for %{public}@", indexPaths.logDescription)
	}

	public func startPrefetching(indexPaths: [IndexPath], with fetchedResultsController: NSFetchedResultsController<ResultType>) {
		guard pendingPrefetchResults[indexPaths] == nil else {
			loggingService.log(.info, "Prefetch for %{public}@ already in progress", indexPaths.logDescription)
			return
		}
		let results = indexPaths.map { fetchedResultsController.object(at: $0) }
		guard let fetchRequest = fetchRequestForPrefetching(results: results, from: fetchedResultsController.fetchRequest) else { return }
 		let asyncFetchRequest = NSAsynchronousFetchRequest(fetchRequest: fetchRequest) { result in
			assert(Thread.isMainThread, "Expecting main thread updates only")
			guard let cachedResult = self.pendingPrefetchResults.removeValue(forKey: indexPaths) else { return }
			if cachedResult !== result {
				self.loggingService.log(.info, "Surprise result! Putting back")
				self.pendingPrefetchResults[indexPaths] = cachedResult
			}
			if let error = result.operationError {
				self.handlePrefetchError(error)
			}
			if let finalResult = result.finalResult {
				self.loggingService.log(.info, "Prefetching %{public}@ complete: %ld items", indexPaths.logDescription, finalResult.count)
				self.processPrefetchResults(finalResult)
			}
		}
		let context = fetchedResultsController.managedObjectContext
		var result: Result<NSPersistentStoreAsynchronousResult, Error>!
		context.performAndWait {
			do {
				result = .success(try context.execute(asyncFetchRequest) as! NSPersistentStoreAsynchronousResult)
			} catch {
				result = .failure(error)
			}
		}
		switch result! {
		case .success(let result):
			pendingPrefetchResults[indexPaths] = result
		case .failure(let error):
			handlePrefetchError(error)
		}
	}
}

// Prevent bridging of IndexPath to NSIndexPath when calling logging functions
fileprivate extension Array where Element == IndexPath {

	var logDescription: String {
		return "IndexPaths(\(map({ "[\($0[0]),\($0[1])]" }).joined(separator: ", ")))"
	}
}
