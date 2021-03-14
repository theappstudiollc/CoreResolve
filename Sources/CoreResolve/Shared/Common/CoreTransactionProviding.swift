//
//  CoreTransactionProviding.swift
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

/// Provides a mechanism to begin, commit, and cancel transactions
public protocol CoreTransactionProviding {
	
	/// An implementation-specific context used to cancel or commit transactions. Refer to the documentation on specific implementations to determine requirements and use-cases regarding this type
	associatedtype TransactionContext
	
	/// Begins a transaction with the intention of committing or cancelling it. It also returns the existing undoManager in case the caller wants to restore state
	@discardableResult func beginTransaction() -> TransactionContext?
	
	/// Cancels a transaction. Does nothing if a transaction was not begun
	func cancelTransaction()
	
	/// Commits a transaction, and throws an error if the transaction could not be committed. It should be safe to commit a transaction without first beginning one
	func commitTransaction() throws
	
	/// Cancels a transaction. Does nothing if a transaction was not begun. This function is an optional implementation of `cancelTransaction()` that restores the state of the provider using the return value from `beginTransaction()`
	func cancelTransaction(transactionContext: TransactionContext?)
	
	/// Commits a transaction, and throws an error if the transaction could not be committed. It should be safe to commit a transaction without first beginning one. This function is an optional implementation of `commitTransaction()` that restores the state of the provider using the return value from `beginTransaction()`. If this function throws, you should then use `cancelTransaction(transactionContext:)` to cancel and restore the state of the provider
	func commitTransaction(transactionContext: TransactionContext?) throws
}
