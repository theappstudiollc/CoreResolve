//
//  CoreTableDataSource.swift
//  CoreResolve
//
//  Created by David Mitchell
//  Copyright © 2020 The App Studio LLC.
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

#if canImport(WatchKit)

import CoreData
import WatchKit

open class CoreTableDataSource<Table>: FetchedResultsControllerDataSource<Table.CellType.ResultType> where Table: CoreTable {

	public unowned let table: Table

	public init(for table: Table, with fetchController: @escaping FetchController) {
		self.table = table
		super.init(with: fetchController)
	}

	open func reloadIfNeeded() {
		guard _fetchedResultsController == nil else { return }
		guard let sections = fetchedResultsController.sections, sections.count == 1 else {
			fatalError("Multiple sections are unsupported by \(Self.self)")
		}
		let section = 0
		let rows = sections[section].numberOfObjects
		guard rows > 0 else { return }
		var next = nextRowType(with: 0..<rows, in: section)
		table.setNumberOfRows(next.range.count, withRowType: next.rowType)
		next.values.forEach { value in
			applyResult(value.value, at: value.key)
		}
		while next.range.upperBound < rows {
			next = nextRowType(with: next.range.upperBound..<rows, in: section)
			table.insertRows(at: IndexSet(integersIn: next.range), withRowType: next.rowType)
			next.values.forEach { value in
				applyResult(value.value, at: value.key)
			}
		}
	}

	// MARK: - Private properties and methods

	func applyResult(_ result: Table.CellType.ResultType, at indexPath: IndexPath) {
		guard let rowController = table.rowController(at: indexPath.row) as? Table.CellType else {
			fatalError("Unsupported RowController type")
		}
		rowController.applyResult(result)
	}

	func nextRowType(with range: Range<Int>, in section: Int) -> (range: Range<Int>, rowType: String, values: [IndexPath : Table.CellType.ResultType]) {
		var values = [IndexPath : Table.CellType.ResultType](minimumCapacity: range.count)
		var currentIndexPath = IndexPath(row: range.lowerBound, section: section)
		var currentResult = fetchedResultsController.object(at: currentIndexPath)
		values[currentIndexPath] = currentResult
		let currentRowType = table.cellIdentifierFor(result: currentResult)
		for row in range.dropFirst() {
			currentIndexPath = IndexPath(row: row, section: section)
			currentResult = fetchedResultsController.object(at: currentIndexPath)
			if table.cellIdentifierFor(result: currentResult) != currentRowType {
				return (range: range.lowerBound..<row, rowType: currentRowType, values: values)
			}
			values[currentIndexPath] = currentResult
		}
		return (range: range, rowType: currentRowType, values: values)
	}

	struct TableChanges {
		var deletes = [IndexPath]()
		var inserts = [(result: Table.CellType.ResultType, indexPath: IndexPath)]()
		var moves = [(result: Table.CellType.ResultType, fromIndexPath: IndexPath, toIndexPath: IndexPath)]()
		var reloads = [(result: Table.CellType.ResultType, indexPath: IndexPath)]()
	}

	var tableChanges: TableChanges!

	// MARK: - NSFetchedResultsControllerDelegate methods

	open override func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		// First apply deletes (in descending order)
		let sortedDeletes = tableChanges.deletes.sorted().map { $0.row }
		if sortedDeletes.count > 0 {
			table.removeRows(at: IndexSet(sortedDeletes))
		}
		// Then apply inserts (in ascending order)
		for insert in tableChanges.inserts.sorted(by: { $0.indexPath < $1.indexPath }) {
			let rowType = table.cellIdentifierFor(result: insert.result)
			// TODO: We can scan ahead with the rowType and insert as a group (might be faster)
//			print("Inserting \(rowType) @ \(insert.indexPath.row) into table with \(table.numberOfRows) rows")
			table.insertRows(at: IndexSet(integer: insert.indexPath.row), withRowType: rowType)
			applyResult(insert.result, at: insert.indexPath)
		}
		// Now apply moves (in order as delivered)
		for move in tableChanges.moves {
			table.removeRows(at: IndexSet(integer: move.fromIndexPath.row))
			let rowType = table.cellIdentifierFor(result: move.result)
			table.insertRows(at: IndexSet(integer: move.toIndexPath.row), withRowType: rowType)
			applyResult(move.result, at: move.toIndexPath)
		}
		// Finally apply reloads (in order as delivered)
		for reload in tableChanges.reloads {
			applyResult(reload.result, at: reload.indexPath)
		}
		tableChanges = nil
	}

	open override func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
		switch (type, indexPath, newIndexPath, anObject) {
		case (.delete, .some(let indexPath), .none, _):
			tableChanges.deletes.append(indexPath)
		case (.insert, .none, .some(let newIndexPath), let result as Table.CellType.ResultType):
			tableChanges.inserts.append((result: result, indexPath: newIndexPath))
		case (.move, .some(let indexPath), .some(let newIndexPath), let result as Table.CellType.ResultType):
			tableChanges.moves.append((result: result, fromIndexPath: indexPath, toIndexPath: newIndexPath))
		case (.update, .some(let indexPath), _, let result as Table.CellType.ResultType):
			tableChanges.reloads.append((result: result, indexPath: indexPath))
		default:
			fatalError("Unexpected object change: Type=`\(type.rawValue)`, indexPath=`\(String(describing: indexPath))`, newIndexPath=`\(String(describing: newIndexPath))`, anObject=`\(anObject.self)`")
		}
	}

	open override func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		tableChanges = TableChanges()
	}
}

#endif
