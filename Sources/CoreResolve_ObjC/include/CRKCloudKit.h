//
//  CRKCloudKit.h
//  CoreResolve
//
//  Created by David Mitchell
//  Copyright © 2021 The App Studio LLC.
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

/// Contains CloudKit definitions missing from Xcode 12.x, so that apps supporting iOS 9.x may still compile
#ifndef CRKCloudKit_h
#define CRKCloudKit_h

#import <Foundation/Foundation.h>

#ifdef __IPHONE_14_0

#import <CloudKit/CloudKit.h>

#if (TARGET_OS_OSX && !defined(__i386__)) || TARGET_OS_IOS
@class CNContact;
#endif

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, CKSubscriptionOptions) {
	CKSubscriptionOptionsFiresOnRecordCreation     = 1 << 0,
	CKSubscriptionOptionsFiresOnRecordUpdate       = 1 << 1,
	CKSubscriptionOptionsFiresOnRecordDeletion     = 1 << 2,
	CKSubscriptionOptionsFiresOnce                 = 1 << 3,
} API_DEPRECATED("Use CKQuerySubscriptionOptions instead", macos(10.10, 10.12), ios(8.0, 10.0), tvos(9.0, 10.0)) __WATCHOS_PROHIBITED;

@interface CKSubscription (KnownAvailableOnNineOh)
- (instancetype)initWithRecordType:(CKRecordType)recordType predicate:(NSPredicate *)predicate subscriptionID:(CKSubscriptionID)subscriptionID options:(CKSubscriptionOptions)subscriptionOptions API_DEPRECATED("Use CKQuerySubscription instead", macos(10.10, 10.12), ios(8.0, 10.0), tvos(9.0, 10.0)) __WATCHOS_PROHIBITED;
@end

API_DEPRECATED_WITH_REPLACEMENT("CKUserIdentity", macos(10.10, 10.12), ios(8.0, 10.0), tvos(9.0, 10.0), watchos(3.0, 3.0))
@interface CKDiscoveredUserInfo : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@property (nonatomic, readonly, copy, nullable) CKRecordID *userRecordID;

#if (TARGET_OS_OSX && !defined(__i386__)) || TARGET_OS_IOS

@property (nonatomic, readonly, copy, nullable) NSString *firstName API_DEPRECATED("Use CKDiscoveredUserInfo.displayContact.givenName", macos(10.10, 10.11), ios(8.0, 9.0), tvos(9.0, 9.0));
@property (nonatomic, readonly, copy, nullable) NSString *lastName API_DEPRECATED("Use CKDiscoveredUserInfo.displayContact.familyName", macos(10.10, 10.11), ios(8.0, 9.0), tvos(9.0, 9.0));

/*! Not associated with the local Address Book.  It is a wrapper around information known to the CloudKit server, including first and last names */
@property (nonatomic, readonly, copy, nullable) CNContact *displayContact API_AVAILABLE(macos(10.11), ios(9.0));

#else // (TARGET_OS_OSX && !defined(__i386__)) || TARGET_OS_IOS

@property (nonatomic, readonly, copy, nullable) NSString *firstName;
@property (nonatomic, readonly, copy, nullable) NSString *lastName;

#endif // (TARGET_OS_OSX && !defined(__i386__)) || TARGET_OS_IOS

@end

/*! @class CKDiscoverAllContactsOperation
 *
 *  @abstract Finds all discoverable users in the device's address book. No Contacts access dialog will be displayed
 */
API_DEPRECATED_WITH_REPLACEMENT("CKDiscoverAllUserIdentitiesOperation", macos(10.10, 10.12), ios(8.0, 10.0), watchos(3.0, 3.0))
API_UNAVAILABLE(tvos)
@interface CKDiscoverAllContactsOperation : CKOperation

- (instancetype)init NS_DESIGNATED_INITIALIZER;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

@property (nonatomic, copy, nullable) void (^discoverAllContactsCompletionBlock)(NSArray<CKDiscoveredUserInfo *> * _Nullable userInfos, NSError * _Nullable operationError);

#pragma clang diagnostic pop

@end

API_DEPRECATED_WITH_REPLACEMENT("CKDiscoverUserIdentitiesOperation", macos(10.10, 10.12), ios(8.0, 10.0), tvos(9.0, 10.0), watchos(3.0, 3.0))
@interface CKDiscoverUserInfosOperation : CKOperation

- (instancetype)init NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithEmailAddresses:(nullable NSArray<NSString *> *)emailAddresses userRecordIDs:(nullable NSArray<CKRecordID *> *)userRecordIDs;

@property (nonatomic, copy, nullable) NSArray<NSString *> *emailAddresses;
@property (nonatomic, copy, nullable) NSArray<CKRecordID *> *userRecordIDs;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

/*! @abstract This block is called when the operation completes.
 *
 *  @discussion The [NSOperation completionBlock] will also be called if both are set.
 */
@property (nonatomic, copy, nullable) void (^discoverUserInfosCompletionBlock)(NSDictionary<NSString *, CKDiscoveredUserInfo *> * _Nullable emailsToUserInfos, NSDictionary<CKRecordID *, CKDiscoveredUserInfo *> * _Nullable userRecordIDsToUserInfos, NSError * _Nullable operationError);

#pragma clang diagnostic pop

@end

NS_ASSUME_NONNULL_END

#endif

#endif /* CRKCloudKit_h */
