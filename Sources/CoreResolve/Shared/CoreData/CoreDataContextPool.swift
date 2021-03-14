//
//  CoreDataContextPool.swift
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

internal struct CoreDataContextPool {
	
	public let size: Int

	public init(poolSize: UInt) {
		self.size = Int(poolSize)
		self.pool = [ContextReference](repeating: { nil }, count: self.size)
	}
	
	public func contexts() -> [NSManagedObjectContext] {
		return pool.compactMap { $0() }
	}
	
	public mutating func next(_ create: () -> NSManagedObjectContext) -> NSManagedObjectContext {
		for _ in 0 ..< size {
			indexPointer = (indexPointer + 1) % size
			if let retVal = pool[indexPointer]() {
				return retVal
			}
		}
		let retVal = create()
		pool[indexPointer] = { [weak retVal] in retVal }
		return retVal
	}
	
	private typealias ContextReference = () -> NSManagedObjectContext?
	
	internal var indexPointer = 0 // Internal for testability
	private var pool: [ContextReference]
}
