//
//  LegacyUserNotificationManager.swift
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

#if os(macOS)

import AppKit

@available(macOS, deprecated: 10.14)
public final class LegacyUserNotificationManager: CoreRemoteNotificationAdapter, CoreNotificationProviding {

	fileprivate var categories: Set<CoreNotification.Category>?
	fileprivate var notificationCenter: NSUserNotificationCenter
	fileprivate var notificationTypes: NSApplication.RemoteNotificationType?
	fileprivate var registrationHandler: ((Result<Void, Error>) -> Void)?
	
	public init(application: Application, notificationDelegate: CoreRemoteNotificationAdaptingDelegate? = nil, notificationCenter: NSUserNotificationCenter = .default) {
		self.notificationCenter = notificationCenter
		super.init(application: application, notificationDelegate: notificationDelegate)
	}

	public func handleRemoteNotification(_ notification: [String : Any]) {
		// TODO: Pass this to the delegate
	}

	public override func remoteTokenRegistrationFailed(_ error: Error) {
		super.remoteTokenRegistrationFailed(error)
		registrationHandler?(.failure(error))
	}

	public override func remoteTokenRegistrationSucceeded(_ token: Data) {
		super.remoteTokenRegistrationSucceeded(token)
		registrationHandler?(.success(()))
		registrationHandler = nil
	}

	public func requestAuthorization(options: CoreNotification.AuthorizationOptions, completionHandler: @escaping (Result<Void, Error>) -> Void) {
		self.notificationTypes = NSApplication.RemoteNotificationType(from: options)
		self.registrationHandler = completionHandler
		updateAuthorization()
	}
	
	public func setNotificationCategories(_ categories: Set<CoreNotification.Category>) {
		self.categories = categories
		updateAuthorization()
	}

	func updateAuthorization() {
		guard registrationHandler != nil, let notificationTypes = self.notificationTypes else { return }
		assert(Thread.isMainThread, "This call must be called in the main thread")
		application.registerForRemoteNotifications(matching: notificationTypes)
	}
}

extension NSApplication.RemoteNotificationType {
	
	init(from authorizationOptions: CoreNotification.AuthorizationOptions) {
		/*
		var rawValue: UIUserNotificationType.RawValue = 0
		let types: [UIUserNotificationType] = [.badge, .sound, .alert]
		for type in types.filter({ authorizationOptions.rawValue == $0.rawValue }) {
			rawValue &= type.rawValue
		}
		*/
		self.init(rawValue: authorizationOptions.rawValue)
	}
}
/*
extension NSMutableUserNotificationCategory {
	
	convenience init(from category: CoreNotification.Category) {
		self.init()
		self.identifier = category.identifier
		// TODO: Consider how we may want to use .minimal
		self.setActions(nil, for: .default)
	}
}
*/
#endif
