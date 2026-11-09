//
//  CoreDataContextPoolTests.swift
//  CoreResolve
//
//  Created by David Mitchell
//  Copyright © 2026 The App Studio LLC.
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
import Testing
@testable import CoreResolve

struct CoreDataContextPoolTests {
    @Test(arguments: [1, 2, 4])
    func fillsConfiguredSlotsAndReusesInOrder(size: Int) {
        var pool = CoreDataContextPool(poolSize: UInt(size))
        var created = 0
        let create = {
            created += 1
            return NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        }
        #expect(pool.contexts().isEmpty)
        let retained = (0..<size).map { _ in pool.next(create) }
        #expect(Set(retained.map(ObjectIdentifier.init)).count == size)
        #expect(created == size)
        for expected in retained {
            #expect(pool.next(create) === expected)
        }
        #expect(created == size)
        #expect(pool.contexts().count == size)
    }

    @Test func releasedSlotIsRecreatedWithoutReplacingLiveSlots() {
        var pool = CoreDataContextPool(poolSize: 2)
        var first: NSManagedObjectContext? = pool.next {
            NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        }
        let released = { [weak first] in first }
        let second = pool.next {
            NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        }
        first = nil
        #expect(released() == nil)
        #expect(pool.contexts().count == 1)
        var creations = 0
        let replacement = pool.next {
            creations += 1
            return NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        }
        #expect(creations == 1)
        #expect(replacement !== second)
        #expect(pool.next {
            Issue.record("A retained slot must not be recreated")
            return NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        } === second)
        withExtendedLifetime(replacement) {
            #expect(pool.contexts().count == 2)
        }
    }

    @Test func zeroSizedPoolCanBeInspectedWithoutCreatingContexts() {
        // MultiContextCoreDataStack bypasses next() when the configured size is zero.
        let pool = CoreDataContextPool(poolSize: 0)
        #expect(pool.size == 0)
        #expect(pool.contexts().isEmpty)
    }
}
