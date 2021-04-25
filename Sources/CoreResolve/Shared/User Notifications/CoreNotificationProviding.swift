//
//  CoreNotificationProviding.swift
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

import Foundation

/// Handles remote-notification-based events
public protocol CoreRemoteNotificationAdaptingDelegate: AnyObject {

	/// Called by the `CoreRemoteNotificationAdapting` implementation when the device token has been updated
	/// - Parameter token: The app-specific token representing the device
	func deviceTokenDidUpdate(_ token: Data)

	/// Called by the `CoreRemoteNotificationAdapting` implementation when there was a failure to register for remote notifications
	/// - Parameter error: The error describing the failure
	func deviceTokenRegistrationFailed(_ error: Error)
}

public protocol CoreRemoteNotificationAdapting {

	/// Gets the device token, if successfully obtained
	var deviceToken: Data? { get }

	/// Gets or sets the adapting delegate that will respond to events related to remote notification tokens
	var notificationDelegate: CoreRemoteNotificationAdaptingDelegate? { get set }

	/// Registers the application for silent remote notifications
	@available(macOS 10.14, watchOS 6.0, *)
	func registerForRemoteNotifications()

	/// Call this method when the platform fails to obtain a device token so that the adapter may inform the delegate
	func remoteTokenRegistrationFailed(_ error: Error)

	/// Call this method when the platform provides a device token so that the adapter may inform the delegate
	func remoteTokenRegistrationSucceeded(_ token: Data)
}

// TODO: Consider a delegate so that callbacks for notification events can be provided (regardless of legacy notifications or modern ones)

/// Provides User Notification capability to an app. Implementations may choose to provide remote notification capability via initializers or other public properties and methods
public protocol CoreNotificationProviding: CoreRemoteNotificationAdapting {

	/// Requests user authorization for the provided AuthorizationOptions. Depending on the platform and implementation, this call may also register for remote notifications. For tvOS, the only supported `AuthorizationOptions` is `.badge`
	///
	/// - Parameters:
	///   - options: The notification options which to request authorization
	///   - completionHandler: Returns whether the requested authorization options were granted by the user
	func requestAuthorization(options: CoreNotification.AuthorizationOptions, completionHandler: @escaping (Result<Void, Error>) -> Void)

	#if !os(tvOS)

	/// Sets the categories for User Notifications
	///
	/// - Parameter categories: A set of User Notification Categories
	@available(macOS 10.14, *)
	func setNotificationCategories(_ categories: Set<CoreNotification.Category>)

	#endif
}
