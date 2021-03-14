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

#if canImport(UIKit) && !os(watchOS)

import CoreData
import UIKit

open class CoreTableDataSource<TableView>: CoreTableViewDataSource<TableView.CellType.ResultType, TableView> where TableView: CoreTable {

	override public init(for tableView: TableView, with fetchController: @escaping CoreTableViewDataSource<TableView.CellType.ResultType, TableView>.FetchController) {
		super.init(for: tableView, with: fetchController)
		if let prefetcher = getPrefetchDataSource() {
			prefetchDataSource = prefetcher
		}
	}

	open func getPrefetchDataSource() -> AnyPrefetchDataSource<TableView.CellType.ResultType>? {
		return nil
	}

	open override func tableView(_ tableView: TableView, cellFor result: TableView.CellType.ResultType, at indexPath: IndexPath) -> UITableViewCell {
		let identifier = tableView.cellIdentifierFor(result: result)
		let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
		if let resultTypeAware = cell as? TableView.CellType {
			resultTypeAware.applyResult(result)
		}
		return cell
	}
}

#endif
