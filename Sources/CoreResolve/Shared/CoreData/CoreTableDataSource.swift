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

import CoreData

public protocol CoreTableCell: TableViewCell {

	associatedtype ResultType: NSFetchRequestResult

	func applyResult(_ result: ResultType)
}

public protocol CoreTable: TableView {

	associatedtype CellType: CoreTableCell

	func cellIdentifierFor(result: CellType.ResultType) -> String
}
/* Potential shared base implementation
public enum CoreTableDataSourceError: Error {

	case invalidCellType
	case unimplementedMethod
}

#if os(iOS) || os(tvOS)
public protocol CoreTableDataSourceImplements: UITableViewDataSource, UITableViewDataSourcePrefetching { }
#elseif os(macOS)
public protocol CoreTableDataSourceImplements: NSTableViewDataSource, NSTableViewDelegate { }
#else
public protocol CoreTableDataSourceImplements { }
#endif

@available(macOS 10.12, *)
open class CoreTableDataSourceBase<Table>: FetchedResultsControllerDataSource<Table.CellType.ResultType> /*, CoreTableDataSourceImplements*/ where Table: CoreTable {

	public unowned let table: Table

	public init(for table: Table, with fetchController: @escaping FetchController) {
		self.table = table
		super.init(with: fetchController)
		#if os(iOS) || os(tvOS)
		table.dataSource = self
		#elseif os(macOS)
		table.dataSource = self
		table.delegate = self
		#endif
	}

	open func cell(at indexPath: IndexPath) throws -> Table.CellType {
		#if os(iOS) || os(tvOS)
		guard let cell = table.cellForRow(at: indexPath) as? Table.CellType else {
			throw CoreTableDataSourceError.invalidCellType
		}
		return cell
		#elseif os(macOS)
		throw CoreTableDataSourceError.unimplementedMethod
		#else
		guard let cell = table.rowController(at: indexPath.row) as? Table.CellType else {
			throw CoreTableDataSourceError.invalidCellType
		}
		return cell
		#endif
	}

	#if os(iOS) || os(tvOS)

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
		let cell = self.tableView(tableView as! Table, cellFor: result, at: indexPath)
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

	open func tableView(_ tableView: Table, cellFor result: Table.CellType.ResultType, at indexPath: IndexPath) -> UITableViewCell {
		fatalError("\(type(of: self)) is expected to implement tableView(_:cellFor:at:)")
	}

	#elseif os(macOS)

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

	#endif
}
*/
