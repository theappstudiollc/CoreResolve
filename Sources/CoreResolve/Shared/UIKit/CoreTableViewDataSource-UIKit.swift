//
//  CoreTableViewDataSource-UIKit.swift
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

open class CoreTableViewDataSource<ResultType, TableViewType>: FetchedResultsControllerDataSource<ResultType>, UITableViewDataSource, UITableViewDataSourcePrefetching where ResultType: NSFetchRequestResult, TableViewType: UITableView {
	
	/// Assigns a PrefetchDataSource to the TableView DataSource. Has no effect on iOS or tvOS versions less than 10.0
	public var prefetchDataSource: AnyPrefetchDataSource<ResultType>? {
		didSet {
			guard #available(iOS 10.0, tvOS 10.0, *) else { return }
			tableView.prefetchDataSource = prefetchDataSource == nil ? nil : self
		}
	}
	
	public unowned let tableView: TableViewType
	
	public init(for tableView: TableViewType, with fetchController: @escaping FetchController) {
		self.tableView = tableView
		super.init(with: fetchController)
		tableView.dataSource = self
	}
	
	open func reloadIfNeeded() {
		guard _fetchedResultsController == nil else { return }
		tableView.reloadData()
	}
	
	open func rowAnimation(for changeType: NSFetchedResultsChangeType, with object: Any, at indexPath: IndexPath) -> UITableView.RowAnimation {
		return .automatic
	}
	
	open func rowAnimation(for changeType: NSFetchedResultsChangeType, with sectionInfo: NSFetchedResultsSectionInfo, at sectionIndex: Int) -> UITableView.RowAnimation {
		return .automatic
	}

	// MARK: - Private properties and methods

	private var sectionDeletes = Set<Int>()
	private var sectionInserts = Set<Int>()

	// MARK: - NSFetchedResultsControllerDelegate methods
	
	open override func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		sectionDeletes.removeAll()
		sectionInserts.removeAll()
		tableView.endUpdates()
	}
	
	public override func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
		switch (type, indexPath, newIndexPath) {
		case (.delete, .some(let indexPath), .none):
			tableView.deleteRows(at: [indexPath], with: rowAnimation(for: type, with: anObject, at: indexPath))
		case (.insert, .none, .some(let newIndexPath)):
			tableView.insertRows(at: [newIndexPath], with: rowAnimation(for: type, with: anObject, at: newIndexPath))
		case (.move, .some(let indexPath), .some(let newIndexPath)):
			if sectionInserts.contains(newIndexPath.section) {
				let deleteAnimation = rowAnimation(for: type, with: anObject, at: indexPath)
				if sectionDeletes.contains(indexPath.section) || deleteAnimation != .automatic {
					tableView.deleteRows(at: [indexPath], with: deleteAnimation)
				} else {
					tableView.deleteRows(at: [indexPath], with: .bottom)
				}
				tableView.insertRows(at: [newIndexPath], with: rowAnimation(for: type, with: anObject, at: newIndexPath))
			} else if indexPath == newIndexPath {
				tableView.reloadRows(at: [indexPath], with: rowAnimation(for: type, with: anObject, at: indexPath))
			} else {
				tableView.moveRow(at: indexPath, to: newIndexPath)
			}
		case (.update, .some(let indexPath), _): // TODO: Why does `update` have newIndexPath? Always or sometimes?
			if let newIndexPath = newIndexPath {
				assert(indexPath == newIndexPath, "Unexpected update with two index paths: \(indexPath) vs \(newIndexPath)")
			} else {
				fatalError("Why is newIndexPath not present?")
			}
			tableView.reloadRows(at: [indexPath], with: rowAnimation(for: type, with: anObject, at: indexPath))
		default:
			fatalError("Unexpected object change: Type=`\(type.rawValue)`, indexPath=`\(String(describing: indexPath))`, newIndexPath=`\(String(describing: newIndexPath))`")
		}
	}
	
	public override func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
		let animation = rowAnimation(for: type, with: sectionInfo, at: sectionIndex)
		switch type {
		case .delete:
			sectionDeletes.insert(sectionIndex)
			tableView.deleteSections(IndexSet(integer: sectionIndex), with: animation)
		case .insert:
			sectionInserts.insert(sectionIndex)
			tableView.insertSections(IndexSet(integer: sectionIndex), with: animation)
		case .update:
			tableView.reloadSections(IndexSet(integer: sectionIndex), with: animation)
		default:
			fatalError("Unsupported change type: \(type.rawValue)")
		}
	}
	
	open override func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		tableView.beginUpdates()
	}
	
	// MARK: - UITableViewDataSource methods
	
	open func numberOfSections(in tableView: UITableView) -> Int {
		return fetchedResultsController.sections?.count ?? 0
	}
	
	open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let sections = fetchedResultsController.sections, sections.count > section else { return 0 }
		return sections[section].numberOfObjects
	}
	
	open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let result = fetchedResultsController.object(at: indexPath)
		let cell = self.tableView(tableView as! TableViewType, cellFor: result, at: indexPath)
		if let layoutContaining = tableView as? CoreColumnLayoutContaining, var columnLayoutAware = cell as? CoreColumnLayoutAware {
			columnLayoutAware.columnLayoutProvider = layoutContaining.columnLayoutProvider
		}
		if let preparesView = tableView as? CoreTableViewPreparesViewsForSizing, preparesView.cellRequiresPreparation {
			preparesView.prepareViewForSizing(cell)
		}
		return cell
	}
	
	open func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		guard let sections = fetchedResultsController.sections, sections.count > section else { return nil }
		return sections[section].name
	}
	
	// MARK: - UITableViewDataSourcePrefetching methods
	
	public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
		prefetchDataSource?.cancelPrefetching(indexPaths: indexPaths)
	}
	
	public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
		guard #available(iOS 10.0, tvOS 10.0, *) else { return }
		prefetchDataSource?.startPrefetching(indexPaths: indexPaths, with: fetchedResultsController)
	}
	
	// MARK: - Required overrides
	
	open func tableView(_ tableView: TableViewType, cellFor result: ResultType, at indexPath: IndexPath) -> UITableViewCell {
		fatalError("\(type(of: self)) is expected to implement tableView(_:cellFor:at:)")
	}
}

#endif
