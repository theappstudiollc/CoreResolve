//
//  CoreRemoteNotificationAdapter.swift
//  CoreResolve
//
//  Created by David Mitchell
//  Copyright © 2020 The App Studio LLC.
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

open class CoreRemoteNotificationAdapter: NSObject, CoreRemoteNotificationAdapting {

	internal let application: Application
	public private(set) var deviceToken: Data?
	public var notificationDelegate: CoreRemoteNotificationAdaptingDelegate?

	public init(application: Application, notificationDelegate: CoreRemoteNotificationAdaptingDelegate? = nil) {
		self.application = application
		self.notificationDelegate = notificationDelegate
	}

	@available(macOS 10.14, watchOS 6.0, *)
	open func registerForRemoteNotifications() {
		application.registerForRemoteNotifications()
	}

	open func remoteTokenRegistrationFailed(_ error: Error) {
		notificationDelegate?.deviceTokenRegistrationFailed(error)
	}

	open func remoteTokenRegistrationSucceeded(_ token: Data) {
		deviceToken = token
		notificationDelegate?.deviceTokenDidUpdate(token)
	}
}
