//
//  CRKManagedObjectContext.h
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CRKManagedObjectContext: NSObject

/**
 Compatibility bridge for an undo manager confined to an NSManagedObjectContext's
 queue, including a private queue. Swift imports UndoManager as MainActor-isolated;
 these synchronous Objective-C calls deliberately leave isolation to Core Data's
 queue-confinement contract instead.

 Call these helpers only on the owning context's queue (perform/performAndWait).
 The manager, its targets, and its undo actions must all obey that same confinement.
 Do not share a private-context manager with UI code or another context's queue,
 or register handlers that require MainActor on a private-context manager.

 These helpers do not dispatch, lock, or make UndoManager thread-safe. The caller
 is responsible for confinement, including any manager supplied for restoration.
 */
+ (NSUndoManager *)contextUndoManager NS_SWIFT_NAME(contextUndoManager());

/// Begins a group under the context-queue confinement contract above.
+ (void)beginContextUndoGrouping:(NSUndoManager *)manager NS_SWIFT_NAME(beginContextUndoGrouping(_:));

/// Ends a group under the context-queue confinement contract above.
+ (void)endContextUndoGrouping:(NSUndoManager *)manager NS_SWIFT_NAME(endContextUndoGrouping(_:));

/// Performs undo synchronously under the context-queue confinement contract above.
+ (void)undoContextChanges:(NSUndoManager *)manager NS_SWIFT_NAME(undoContextChanges(_:));

@end

NS_ASSUME_NONNULL_END
