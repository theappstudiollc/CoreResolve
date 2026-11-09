//
//  CRKManagedObjectContext.m
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

#import "CRKManagedObjectContext.h"

@implementation CRKManagedObjectContext

// Deliberately synchronous: the caller already runs on the owning context's queue.
// See CRKManagedObjectContext.h for the confinement requirements of this compatibility bridge.
+ (NSUndoManager *)contextUndoManager {
    return [[NSUndoManager alloc] init];
}

+ (void)beginContextUndoGrouping:(NSUndoManager *)manager {
    [manager beginUndoGrouping];
}

+ (void)endContextUndoGrouping:(NSUndoManager *)manager {
    [manager endUndoGrouping];
}

+ (void)undoContextChanges:(NSUndoManager *)manager {
    [manager undo];
}

@end
