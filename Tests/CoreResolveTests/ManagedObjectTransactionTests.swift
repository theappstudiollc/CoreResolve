//
//  ManagedObjectTransactionTests.swift
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

struct ManagedObjectTransactionTests {
    private func makeContext(_ type: NSManagedObjectContextConcurrencyType) throws -> NSManagedObjectContext {
        let entity = NSEntityDescription()
        entity.name = "Item"
        entity.managedObjectClassName = "NSManagedObject"
        let attribute = NSAttributeDescription()
        attribute.name = "name"
        attribute.attributeType = .stringAttributeType
        attribute.isOptional = false
        entity.properties = [attribute]
        let model = NSManagedObjectModel()
        model.entities = [entity]
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        try coordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil)
        let context = NSManagedObjectContext(concurrencyType: type)
        context.persistentStoreCoordinator = coordinator
        return context
    }

    // All transactions and managed-object access remain inside performAndWait, as in Resolve.
    @Test(arguments: [false, true])
    func commitSavesAndRestoresAbsentUndoManager(mainQueue: Bool) throws {
        let context = try makeContext(mainQueue ? .mainQueueConcurrencyType : .privateQueueConcurrencyType)
        try context.performAndWait {
            context.undoManager = nil
            let previous = context.beginTransaction()
            #expect(previous == nil)
            #expect(context.undoManager != nil)
            let item = NSEntityDescription.insertNewObject(forEntityName: "Item", into: context)
            item.setValue("saved", forKey: "name")
            try context.commitTransaction(transactionContext: previous)
            #expect(context.undoManager == nil)
            #expect(!context.hasChanges)
            context.reset()
            let saved = try context.fetch(NSFetchRequest<NSManagedObject>(entityName: "Item"))
            #expect(saved.count == 1)
            #expect(saved.first?.value(forKey: "name") as? String == "saved")
        }
    }

    @Test(arguments: [false, true])
    func cancelRestoresSavedValue(mainQueue: Bool) throws {
        let context = try makeContext(mainQueue ? .mainQueueConcurrencyType : .privateQueueConcurrencyType)
        try context.performAndWait {
            context.undoManager = nil
            let item = NSEntityDescription.insertNewObject(forEntityName: "Item", into: context)
            item.setValue("original", forKey: "name")
            try context.save()
            let previous = context.beginTransaction()
            item.setValue("changed", forKey: "name")
            context.processPendingChanges()
            context.cancelTransaction(transactionContext: previous)
            #expect(item.value(forKey: "name") as? String == "original")
            #expect(context.undoManager == nil)
        }
    }

    @Test func cancelRemovesInsertedObject() throws {
        let context = try makeContext(.privateQueueConcurrencyType)
        try context.performAndWait {
            context.undoManager = nil
            let previous = context.beginTransaction()
            let item = NSEntityDescription.insertNewObject(forEntityName: "Item", into: context)
            item.setValue("discard", forKey: "name")
            context.processPendingChanges()
            context.cancelTransaction(transactionContext: previous)
            let count = try context.count(for: NSFetchRequest<NSFetchRequestResult>(entityName: "Item"))
            #expect(count == 0)
            #expect(context.undoManager == nil)
        }
    }

    @Test @MainActor func cancellationPreservesExistingUndoManager() throws {
        let context = try makeContext(.mainQueueConcurrencyType)
        let manager = UndoManager()
        manager.groupsByEvent = false
        try context.performAndWait {
            context.undoManager = manager
            let previous = context.beginTransaction()
            #expect(previous === manager)
            let item = NSEntityDescription.insertNewObject(forEntityName: "Item", into: context)
            item.setValue("discard", forKey: "name")
            context.processPendingChanges()
            context.cancelTransaction(transactionContext: previous)
            #expect(context.undoManager === manager)
            let count = try context.count(for: NSFetchRequest<NSFetchRequestResult>(entityName: "Item"))
            #expect(count == 0)
        }
    }

    @Test func commitPropagatesValidationFailure() throws {
        let context = try makeContext(.privateQueueConcurrencyType)
        context.performAndWait {
            context.undoManager = nil
            context.beginTransaction()
            _ = NSEntityDescription.insertNewObject(forEntityName: "Item", into: context)
            #expect(throws: (any Error).self) { try context.commitTransaction() }
            #expect(context.hasChanges)
            // Dispose of the failed transaction without assuming an additional undo group is open.
            context.undoManager = nil
            context.rollback()
        }
    }

    @Test func cancellationWithoutUndoManagerIsHarmless() throws {
        let context = try makeContext(.privateQueueConcurrencyType)
        context.performAndWait {
            context.undoManager = nil
            context.cancelTransaction()
            #expect(context.undoManager == nil)
        }
    }
}
