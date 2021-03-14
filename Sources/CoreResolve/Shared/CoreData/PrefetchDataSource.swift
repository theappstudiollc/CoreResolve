//
//  PrefetchDataSource.swift
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

@available(macOS 10.12, *)
/// Represents a prefetching data source
public protocol PrefetchDataSource {

	// The result type of the associated `NSFetchRequestResult`
	associatedtype ResultType: NSFetchRequestResult

	/// Cancels prefetching of the provided index paths
	/// - Parameter indexPaths: The index paths for which to cancel prefetching
	func cancelPrefetching(indexPaths: [IndexPath])

	/// Starts prefetching of the provided index paths
	/// - Parameters:
	///   - indexPaths: The index paths to begin prefetching
	///   - fetchedResultsController: The `NSFetchedResultsController` for the data source
	func startPrefetching(indexPaths: [IndexPath], with fetchedResultsController: NSFetchedResultsController<ResultType>)
}

@available(macOS 10.12, *)
public extension PrefetchDataSource {

	/// Convenience method to convert any `PrefetchDataSource` to an `AnyPrefetchDataSource<ResultType>`
	func toAny() -> AnyPrefetchDataSource<Self.ResultType> {
		return AnyPrefetchDataSource(self)
	}
}

@available(macOS 10.12, *)
/// Wraps any prefetching data source for use with generic classes where only the ResultType needs to be known
public struct AnyPrefetchDataSource<ResultType>: PrefetchDataSource where ResultType: NSFetchRequestResult {

//	private let dataSource: _AnyPrefetchDataSourceBase<ResultType>
	private let cancelPrefetchingClosure: ([IndexPath]) -> Void
	private let startPrefetchingClosure: ([IndexPath], NSFetchedResultsController<ResultType>) -> Void

	public init<ConcretePrefetchDataSource>(_ dataSource: ConcretePrefetchDataSource) where ConcretePrefetchDataSource: PrefetchDataSource, ConcretePrefetchDataSource.ResultType == ResultType {
//		self.dataSource = _AnyPrefetchDataSourceBox(dataSource)
		self.cancelPrefetchingClosure = dataSource.cancelPrefetching
		self.startPrefetchingClosure = dataSource.startPrefetching
	}

	public func cancelPrefetching(indexPaths: [IndexPath]) {
//		dataSource.cancelPrefetching(indexPaths: indexPaths)
		cancelPrefetchingClosure(indexPaths)
	}

	public func startPrefetching(indexPaths: [IndexPath], with fetchedResultsController: NSFetchedResultsController<ResultType>) {
//		dataSource.startPrefetching(indexPaths: indexPaths, with: fetchedResultsController)
		startPrefetchingClosure(indexPaths, fetchedResultsController)
	}
}
/*
@available(macOS 10.12, *)
/// Abstract base for type-erasing a PrefetchDataSource. All methods will cause a fatalError, so do not call super
fileprivate class _AnyPrefetchDataSourceBase<ResultType>: PrefetchDataSource where ResultType: NSFetchRequestResult {

	init() { guard type(of: self) != _AnyPrefetchDataSourceBase.self else { fatalError("\(self) is abstract") } }

	func cancelPrefetching(indexPaths: [IndexPath]) { fatalError() }

	func startPrefetching(indexPaths: [IndexPath], with fetchedResultsController: NSFetchedResultsController<ResultType>) { fatalError() }
}

@available(macOS 10.12, *)
/// Type-erasing container for a concrete implementation of PrefetchDataSource
fileprivate final class _AnyPrefetchDataSourceBox<ConcretePrefetchDataSource>: _AnyPrefetchDataSourceBase<ConcretePrefetchDataSource.ResultType> where ConcretePrefetchDataSource: PrefetchDataSource {

	private let dataSource: ConcretePrefetchDataSource

	init(_ dataSource: ConcretePrefetchDataSource) {
		self.dataSource = dataSource
	}

	override func cancelPrefetching(indexPaths: [IndexPath]) {
		dataSource.cancelPrefetching(indexPaths: indexPaths)
	}

	override func startPrefetching(indexPaths: [IndexPath], with fetchedResultsController: NSFetchedResultsController<ResultType>) {
		dataSource.startPrefetching(indexPaths: indexPaths, with: fetchedResultsController)
	}
}
*/
