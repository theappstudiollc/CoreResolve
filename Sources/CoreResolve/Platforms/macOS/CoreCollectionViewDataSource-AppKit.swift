//
//  CoreCollectionViewDataSource.swift
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

#if os(macOS)

import AppKit
import CoreData

@available(macOS 10.12, *)
open class CoreCollectionViewDataSource<ResultType, CollectionViewType>: FetchedResultsControllerDataSource<ResultType>, NSCollectionViewDataSource, NSCollectionViewPrefetching where ResultType: NSFetchRequestResult, CollectionViewType: NSCollectionView {
	
	public unowned let collectionView: CollectionViewType

	/// Assigns a PrefetchDataSource to the CollectionView DataSource. Has no effect on macOS versions less than 10.13
	public var prefetchDataSource: AnyPrefetchDataSource<ResultType>? {
		didSet {
			guard #available(macOS 10.13, *) else { return }
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
			if let sectionChanges = fetchedResultSectionChanges {
				for sectionChange in sectionChanges {
					switch sectionChange.0 {
					case .delete:
						collectionView.deleteSections(IndexSet(integer: sectionChange.1))
					case .insert:
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
					case (.insert, .indexPath(let newIndexPath)):
						collectionView.insertItems(at: [newIndexPath])
					case (.move, .indexPaths(let indexPath, let newIndexPath)):
						if indexPath == newIndexPath {
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
		switch type {
		case .delete, .update:
			guard let indexPath = indexPath else { return }
			fetchedResultItemChanges?.append((type, .indexPath(indexPath)))
		case .insert:
			guard let newIndexPath = newIndexPath else { return }
			fetchedResultItemChanges?.append((type, .indexPath(newIndexPath)))
		case .move:
			guard let indexPath = indexPath, let newIndexPath = newIndexPath else { return }
			fetchedResultItemChanges?.append((type, .indexPaths(indexPath, newIndexPath)))
		@unknown default:
			fatalError()
		}
	}
	
	public override func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
		fetchedResultSectionChanges?.append((type, sectionIndex))
	}
	
	open override func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		fetchedResultItemChanges = []
		fetchedResultSectionChanges = []
	}
	
	// MARK: - NSCollectionViewDataSource methods
	
	public func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
		guard let sectionInfo = fetchedResultsController.sections?[section] else { return 0 }
		return sectionInfo.numberOfObjects
	}
	
	public func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
		let result = fetchedResultsController.object(at: indexPath)
		return self.collectionView(collectionView as! CollectionViewType, cellFor: result, at: indexPath)
	}
	
	public func numberOfSections(in collectionView: NSCollectionView) -> Int {
		return fetchedResultsController.sections?.count ?? 0
	}
	
//	public func collectionView(_ collectionView: NSCollectionView, viewForSupplementaryElementOfKind kind: NSCollectionView.SupplementaryElementKind, at indexPath: IndexPath) -> NSView
	
	// MARK: - NSCollectionViewPrefetching methods
	
	public func collectionView(_ collectionView: NSCollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
		prefetchDataSource?.cancelPrefetching(indexPaths: indexPaths)
	}
	
	public func collectionView(_ collectionView: NSCollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
		guard #available(macOS 10.13, *) else { return }
		prefetchDataSource?.startPrefetching(indexPaths: indexPaths, with: fetchedResultsController)
	}
	
	// MARK: - Required overrides
	
	open func collectionView(_ collectionView: CollectionViewType, cellFor result: ResultType, at indexPath: IndexPath) -> NSCollectionViewItem {
		fatalError("Subclasses are expected to implement collectionView(_:cellFor:at:)")
	}
}

#endif
