//
//  ManagedObject-Extensions.swift
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

import CoreData

extension NSManagedObjectContext: CoreTransactionProviding {
	
	/// `NSManagedObjectContexts` use an `UndoManager` for their transaction contexts
	public typealias TransactionContext = UndoManager
	
	/// Begins a transaction with the intention of committing or cancelling it. If you need to capture the `TransactionContext`, for example to use `cancelTransaction(transactionContext:)` without having called `beginTransaction()`, you may simply save the `undoManager` before calling this function
	@discardableResult public func beginTransaction() -> TransactionContext? {
		let result = undoManager
		if undoManager == nil {
			undoManager = UndoManager()
		}
		undoManager!.beginUndoGrouping()
		return result
	}
	
	/// Cancels a transaction. Does nothing if a transaction was not begun
	public func cancelTransaction() {
		guard let undoManager = undoManager else { return }
		undoManager.endUndoGrouping()
		rollback()
	}
	
	/// Commits a transaction, and throws an error if the transaction could not be committed. It should be safe to commit a transaction without first beginning one
	public func commitTransaction() throws {
		if let undoManager = undoManager {
			undoManager.endUndoGrouping()
		}
		try save()
	}
	
	/// Cancels a transaction. Does nothing if a transaction was not begun. This function is an optional implementation of `cancelTransaction()` that restores the state of the provider using the return value from `beginTransaction()`. If you have logic that may not call `beginTransaction()`, you may use the `undoManager` property before calling `beginTransaction()` to capture the transactionContext
	public func cancelTransaction(transactionContext: TransactionContext?) {
		cancelTransaction()
		undoManager = transactionContext
	}
	
	/// Commits a transaction, and throws an error if the transaction could not be committed. It should be safe to commit a transaction without first beginning one. This function is an optional implementation of `commitTransaction()` that restores the state of the provider using the return value from `beginTransaction()`. If this function throws, you should then use `cancelTransaction(transactionContext:)` to cancel and restore the state of the provider
	public func commitTransaction(transactionContext: TransactionContext?) throws {
		try commitTransaction()
		undoManager = transactionContext
	}
}
