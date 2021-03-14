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

#if os(macOS)

import AppKit

@available(macOS 10.12, *)
open class CoreTableDataSource<TableView>: CoreTableViewDataSource<TableView.CellType.ResultType, TableView> where TableView: CoreTable {

	open override func tableView(_ tableView: TableView, cellFor result: TableView.CellType.ResultType, at indexPath: IndexPath) -> NSView {
		let identifier = tableView.cellIdentifierFor(result: result)
		let itemIdentifier = NSUserInterfaceItemIdentifier(rawValue: identifier)
		let cell = tableView.makeView(withIdentifier: itemIdentifier, owner: nil)
		if let resultTypeAware = cell as? TableView.CellType {
			resultTypeAware.applyResult(result)
		}
		return cell!
	}
}

#endif
