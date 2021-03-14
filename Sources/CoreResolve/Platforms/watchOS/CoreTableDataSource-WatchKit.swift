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

	// MARK: - NSFetchedResultsControllerDelegate methods
	/*
	open override func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
	table.endUpdates()
	}
	*/
	public override func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
		switch (type, indexPath, newIndexPath, anObject) {
		case (.delete, .some(let indexPath), .none, _):
			table.removeRows(at: IndexSet(integer: indexPath.row))
		case (.insert, .none, .some(let newIndexPath), let result as Table.CellType.ResultType):
			let rowType = table.cellIdentifierFor(result: result)
			print("Inserting \(rowType) @ \(newIndexPath.row) into table with \(table.numberOfRows) rows")
			let indexPath = newIndexPath.row > table.numberOfRows ? IndexPath(row: table.numberOfRows, section: newIndexPath.section) : newIndexPath
			if table.numberOfRows == 0 {
				table.setNumberOfRows(1, withRowType: rowType)
			} else {
				table.insertRows(at: IndexSet(integer: indexPath.row), withRowType: rowType)
			}
			applyResult(result, at: indexPath)
		case (.move, .some(let indexPath), .some(let newIndexPath), let result as Table.CellType.ResultType):
			table.removeRows(at: IndexSet(integer: indexPath.row))
			let rowType = table.cellIdentifierFor(result: result)
			table.insertRows(at: IndexSet(integer: newIndexPath.row), withRowType: rowType)
			applyResult(result, at: newIndexPath)
		case (.update, .some(let indexPath), _, let result as Table.CellType.ResultType):
			applyResult(result, at: indexPath)
		default:
			fatalError("Unexpected object change: Type=`\(type.rawValue)`, indexPath=`\(String(describing: indexPath))`, newIndexPath=`\(String(describing: newIndexPath))`, anObject=`\(anObject.self)`")
		}
	}
	/*
	open override func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
	table.beginUpdates()
	}
	*/
}

#endif
