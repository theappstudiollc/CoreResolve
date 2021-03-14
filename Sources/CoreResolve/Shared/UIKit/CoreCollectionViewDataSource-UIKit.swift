//
//  CoreCollectionViewDataSource.swift
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

#if canImport(UIKit) && !os(watchOS)

import CoreData
import UIKit

open class CoreCollectionViewDataSource<ResultType, CollectionViewType>: FetchedResultsControllerDataSource<ResultType>, UICollectionViewDataSource, UICollectionViewDataSourcePrefetching where ResultType: NSFetchRequestResult, CollectionViewType: UICollectionView {
	
	public unowned let collectionView: CollectionViewType
	
	/// Assigns a PrefetchDataSource to the CollectionView DataSource. Has no effect on iOS or tvOS versions less than 10.0
	public var prefetchDataSource: AnyPrefetchDataSource<ResultType>? {
		didSet {
			guard #available(iOS 10.0, tvOS 10.0, *) else { return }
			collectionView.prefetchDataSource = prefetchDataSource == nil ? nil : self
		}
	}
	
	public init(for collectionView: CollectionViewType, with fetchController: @escaping FetchController) {
		self.collectionView = collectionView
		super.init(with: fetchController)
		collectionView.dataSource = self
	}
	
	open func reloadIfNeeded() {
		guard _fetchedResultsController == nil else { return }
		collectionView.reloadData()
	}
	
	enum FetchedResultItemChangeType {
		case indexPath(_ indexPath: IndexPath)
		case indexPaths(_ indexPath: IndexPath, _ newIndexPath: IndexPath)
	}

	var fetchedResultItemChanges: [(NSFetchedResultsChangeType, FetchedResultItemChangeType)]?
	var fetchedResultSectionChanges: [(NSFetchedResultsChangeType, Int)]?
	
	// MARK: - NSFetchedResultsControllerDelegate methods
	
	open override func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		collectionView.performBatchUpdates({
			var sectionInserts = Set<Int>()
			if let sectionChanges = fetchedResultSectionChanges {
				for sectionChange in sectionChanges {
					switch sectionChange.0 {
					case .delete:
						collectionView.deleteSections(IndexSet(integer: sectionChange.1))
					case .insert:
						sectionInserts.insert(sectionChange.1)
						collectionView.insertSections(IndexSet(integer: sectionChange.1))
					default:
						fatalError("Unsupported section change type: \(sectionChange.0.rawValue)")
					}
				}
			}
			if let itemChanges = self.fetchedResultItemChanges {
				for itemChange in itemChanges {
					switch (itemChange.0, itemChange.1) {
					case (.delete, .indexPath(let indexPath)):
						collectionView.deleteItems(at: [indexPath])
					case (.insert, .indexPath(let indexPath)):
						collectionView.insertItems(at: [indexPath])
					case (.move, .indexPaths(let indexPath, let newIndexPath)):
						if sectionInserts.contains(newIndexPath.section) {
							collectionView.deleteItems(at: [indexPath])
							collectionView.insertItems(at: [newIndexPath])
						} else if indexPath == newIndexPath {
							collectionView.reloadItems(at: [indexPath])
						} else {
							collectionView.moveItem(at: indexPath, to: newIndexPath)
						}
					case (.update, .indexPath(let indexPath)):
						collectionView.reloadItems(at: [indexPath])
					default:
						fatalError("Unsupported item change type: \(itemChange.0.rawValue), \(itemChange.1)")
					}
				}
			}
		}) { (finished) in
			self.fetchedResultItemChanges = nil
			self.fetchedResultSectionChanges = nil
		}
	}
	
	public override func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
		switch (type, indexPath, newIndexPath) {
		case (.delete, .some(let indexPath), .none):
			fetchedResultItemChanges?.append((type, .indexPath(indexPath)))
		case (.insert, .none, .some(let newIndexPath)):
			fetchedResultItemChanges?.append((type, .indexPath(newIndexPath)))
		case (.move, .some(let indexPath), .some(let newIndexPath)):
			fetchedResultItemChanges?.append((type, .indexPaths(indexPath, newIndexPath)))
		case (.update, .some(let indexPath), _): // TODO: Why does `update` sometimes have newIndexPath?
			if let newIndexPath = newIndexPath {
				assert(indexPath == newIndexPath, "Unexpected update with two index paths: \(indexPath) vs \(newIndexPath)")
			}
			fetchedResultItemChanges?.append((type, .indexPath(indexPath)))
		default:
			fatalError("Unexpected object change: Type=`\(type.rawValue)`, indexPath=`\(String(describing: indexPath))`, newIndexPath=`\(String(describing: newIndexPath))`")
		}
	}
	
	public override func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
		fetchedResultSectionChanges?.append((type, sectionIndex))
	}
	
	open override func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		fetchedResultItemChanges = []
		fetchedResultSectionChanges = []
	}

	// MARK: - UICollectionViewDataSource methods
	
	public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		guard let sectionInfo = fetchedResultsController.sections?[section] else { return 0 }
		return sectionInfo.numberOfObjects
	}
	
	public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let result = fetchedResultsController.object(at: indexPath)
		return self.collectionView(collectionView as! CollectionViewType, cellFor: result, at: indexPath)
	}
	
	public func numberOfSections(in collectionView: UICollectionView) -> Int {
		return fetchedResultsController.sections?.count ?? 0
	}
	
	// MARK: - UICollectionViewDataSourcePrefetching methods
	
	public func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
		prefetchDataSource?.cancelPrefetching(indexPaths: indexPaths)
	}
	
	public func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
		guard #available(iOS 10.0, tvOS 10.0, *) else { return }
		prefetchDataSource?.startPrefetching(indexPaths: indexPaths, with: fetchedResultsController)
	}
	
	// MARK: - Required overrides

	open func collectionView(_ collectionView: CollectionViewType, cellFor result: ResultType, at indexPath: IndexPath) -> UICollectionViewCell {
		fatalError("\(type(of: self)) is expected to implement collectionView(_:cellFor:at:)")
	}
}

#endif
