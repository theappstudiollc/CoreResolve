//
//  CRKObjectiveC.h
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CRKObjectiveC: NSObject

/**
 Method to enable Swift code to catch Objective-C NSExceptions for API's that aren't marked with throws.
 @param tryBlock Block to execute the code
 @param error optional NSError pointer to recieve an NSError for the thrown NSException
 @return true if no exception, false if an exception was thrown
 */
+ (BOOL)catchExceptionAndThrow:(__attribute__((noescape)) void (^)(void))tryBlock error:(NSError* __autoreleasing _Nullable *)error;

@end

NS_ASSUME_NONNULL_END
