//
//  CoreTableViewDataSource-AppKit.swift
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

@available(macOS 10.12, *)
open class CoreTableViewDataSource<ResultType, TableViewType>: FetchedResultsControllerDataSource<ResultType>, NSTableViewDataSource, NSTableViewDelegate where ResultType: NSFetchRequestResult, TableViewType: NSTableView {
	
	public unowned let tableView: TableViewType

	public init(for tableView: TableViewType, with fetchController: @escaping FetchController) {
		self.tableView = tableView
		super.init(with: fetchController)
		tableView.dataSource = self
		tableView.delegate = self
	}
	
	open func reloadIfNeeded() {
		guard _fetchedResultsController == nil else { return }
		sectionInfos = nil
		tableView.reloadData()
	}
	
	open func rowAnimation(for changeType: NSFetchedResultsChangeType, with object: Any, at indexPath: IndexPath) -> NSTableView.AnimationOptions {
		return .effectGap
	}
	
	open func rowAnimation(for changeType: NSFetchedResultsChangeType, with sectionInfo: NSFetchedResultsSectionInfo, at sectionIndex: Int) -> NSTableView.AnimationOptions {
		return .effectGap
	}

	// MARK: - NSFetchedResultsControllerDelegate methods
	
	open override func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		tableView.endUpdates()
		setupSections()
	}
	
	public override func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
		switch type {
		case .delete:
			guard let indexPath = indexPath else { fatalError("Expecting an indexPath") }
			let row = rowIndex(for: indexPath)
			tableView.removeRows(at: [row], withAnimation: rowAnimation(for: type, with: anObject, at: indexPath))
			sectionInfos[indexPath.section] -= 1
		case .insert:
			guard let newIndexPath = newIndexPath else { fatalError("Expecting a newIndexPath") }
			let row = rowIndex(for: newIndexPath)
			tableView.insertRows(at: [row], withAnimation: rowAnimation(for: type, with: anObject, at: newIndexPath))
			sectionInfos[newIndexPath.section] += 1
		case .move:
			guard let indexPath = indexPath, let newIndexPath = newIndexPath else { fatalError("Expecting a newIndexPath") }
			let row = rowIndex(for: indexPath)
			if indexPath == newIndexPath {
				let columns = IndexSet(integersIn: 0..<numberOfColumnsFor(tableView: tableView))
				tableView.reloadData(forRowIndexes: [row], columnIndexes: columns)
			} else {
				let newRow = rowIndex(for: newIndexPath)
				tableView.moveRow(at: row, to: newRow)
				sectionInfos[indexPath.section] -= 1
				sectionInfos[newIndexPath.section] += 1
			}
		case .update:
			guard let indexPath = indexPath else { fatalError("Expecting an indexPath") }
			let row = rowIndex(for: indexPath)
			let columns = IndexSet(integersIn: 0..<numberOfColumnsFor(tableView: tableView))
			tableView.reloadData(forRowIndexes: [row], columnIndexes: columns)
		@unknown default:
			fatalError()
		}
	}
	
	public override func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {

		let animation = rowAnimation(for: type, with: sectionInfo, at: sectionIndex)
		let startIndex = rowIndex(for: IndexPath(indexes: [sectionIndex, -1]))

		switch type {
		case .delete: // Delete rows based on known (existing) section count
			let endIndex = startIndex + 1 + sectionInfos[sectionIndex]
			tableView.removeRows(at: IndexSet(integersIn: startIndex..<endIndex), withAnimation: animation)
			sectionInfos.remove(at: sectionIndex)
		case .insert: // Insert rows based on new section count
			guard let sections = controller.sections else { fatalError("Expecting some sections") }
			let endIndex = startIndex + sections[sectionIndex].numberOfObjects
			tableView.insertRows(at: IndexSet(integersIn: startIndex..<endIndex), withAnimation: animation)
			sectionInfos.insert(endIndex - startIndex, at: sectionIndex)
		default:
			fatalError("Unsupported change type: \(type.rawValue)")
		}
	}
	
	open override func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		tableView.beginUpdates()
	}
	
	// MARK: - Private properties

	private var sectionInfos: [Int]!

	private func indexPath(for row: Int, column: Int = -1) -> IndexPath {
		guard fetchedResultsController.sectionNameKeyPath != nil else {
			return IndexPath(column: column, row: row, section: 0)
		}
		guard let sections = fetchedResultsController.sections else { fatalError("Expecting some sections") }
		var remainingRows = row
		for section in 0..<sections.count {
			let sectionCount = sections[section].numberOfObjects
			guard remainingRows > sectionCount else {
				return IndexPath(column: column, row: remainingRows - 1, section: section)
			}
			remainingRows -= sectionCount + 1
		}
		return IndexPath(column: column, row: remainingRows - 1, section: sections.count - 1)
	}
	
	private func numberOfRows(in section: Int) -> Int {
		guard let sections = fetchedResultsController.sections, sections.count > 0 else { return 0 }
		return sections[section].numberOfObjects
	}
	
	private func numberOfSections() -> Int {
		guard let sections = fetchedResultsController.sections else { return 0 }
		return sections.count
	}
	
	private func rowIndex(for indexPath: IndexPath) -> Int {
		var retVal: Int = 0
		for section in 0...indexPath.section {
			retVal += 1 + (section == indexPath.section ? indexPath.row : sectionInfos[section])
		}
		return retVal
	}

	private func setupSections() {
		guard let sections = fetchedResultsController.sections else { fatalError("Expecting some sections") }
		sectionInfos = sections.map { $0.numberOfObjects }
	}
	
	// MARK: - NSTableViewDelegate methods
	
	public func tableView(_ tableView: NSTableView, isGroupRow row: Int) -> Bool {
		return indexPath(for: row).row == -1
	}
	
	public func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		let column = self.numberOfColumnsFor(tableView: tableView as! TableViewType) > 1 && tableColumn != nil ?
			self.tableView(tableView as! TableViewType, indexFor: tableColumn!) : 0
		let indexPath = self.indexPath(for: row, column: column)
		guard indexPath.row >= 0 else {
			guard let sections = fetchedResultsController.sections, sections.count > indexPath.section else { return nil }
			return self.tableView(tableView as! TableViewType, rowCellWith: sections[indexPath.section].name, at: indexPath)
		}
		let result = fetchedResultsController.object(at: indexPath)
		return self.tableView(tableView as! TableViewType, cellFor: result, at: indexPath)
	}
	
	public func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
		let indexPath = self.indexPath(for: row)
		if indexPath.row == -1 {
			return self.tableView(tableView as! TableViewType, headerFor: indexPath.section)
		}
		let result = fetchedResultsController.object(at: indexPath)
		return self.tableView(tableView as! TableViewType, rowFor: result, at: indexPath)
	}
	
	// MARK: - NSTableViewDataSource methods
	
	public func numberOfRows(in tableView: NSTableView) -> Int {
		guard let sections = fetchedResultsController.sections, sections.count > 0 else { return 0 }
		if sectionInfos == nil {
			setupSections()
		}
		var retVal = fetchedResultsController.sectionNameKeyPath != nil ? sections.count : 0
		for section in 0..<sections.count {
			retVal += sections[section].numberOfObjects
		}
		return retVal
	}
	
	// MARK: - Required overrides
	
	open func numberOfColumnsFor(tableView: TableViewType) -> Int {
		return 1
	}
	
	open func tableView(_ tableView: TableViewType, indexFor column: NSTableColumn) -> Int {
		fatalError("\(type(of: self)) is expected to implement tableView(_:indexFor:) when `fetchedResultsController.sectionNameKeyPath` is not nil")
	}
	
	open func tableView(_ tableView: TableViewType, cellFor result: ResultType, at indexPath: IndexPath) -> NSView {
		fatalError("\(type(of: self)) is expected to implement tableView(_:cellFor:at:)")
	}
	
	open func tableView(_ tableView: TableViewType, rowCellWith title: String, at indexPath: IndexPath) -> NSView {
		fatalError("\(type(of: self)) is expected to implement tableView(_:cellFor:title:)")
	}
	
	open func tableView(_ tableView: TableViewType, headerFor section: Int) -> NSTableRowView? {
		return nil
	}
	
	open func tableView(_ tableView: TableViewType, rowFor result: ResultType, at indexPath: IndexPath) -> NSTableRowView? {
		return nil
	}
}

#endif
