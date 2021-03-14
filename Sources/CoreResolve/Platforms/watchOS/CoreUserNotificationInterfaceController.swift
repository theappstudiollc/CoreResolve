//
//  CoreUserNotificationInterfaceController.swift
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

// NOTE: The order of these #if statements matter, in order to support all platforms + Interface Builder + deployment scenarios

#if canImport(WatchKit)

import UserNotifications
import WatchKit

#if TARGET_INTERFACE_BUILDER || targetEnvironment(simulator)

open class CoreUserNotificationInterfaceController: WKUserNotificationInterfaceController { }

#elseif DEBUG

/// Core view controller, that enables CorePrintsSupporting capabilities in DEBUG mode
open class CoreUserNotificationInterfaceController: WKUserNotificationInterfaceController, CorePrintsSupporting {

	// MARK: - Common WKInterfaceController lifecycle events

	deinit {
		printsDeinit()
	}

	override public init() {
		super.init()
		printsInit()
	}

	override open func awake(withContext context: Any?) {
		super.awake(withContext: context)
		printsAwakeWithContext(context)
	}

	override open func didAppear() {
		super.didAppear()
		printsDidAppear()
	}

	override open func didDeactivate() {
		super.didDeactivate()
		printsDidDeactivate()
	}

	@available(watchOS 5.0, *)
	override open func didReceive(_ notification: UNNotification) {
		super.didReceive(notification)
		printsDidReceive(notification)
	}

	@available(watchOS 3.0, *)
	override open func didReceive(_ notification: UNNotification, withCompletion completionHandler: @escaping (WKUserNotificationInterfaceType) -> Swift.Void) {
		super.didReceive(notification, withCompletion: completionHandler)
		printsDidReceive(notification, withCompletion: completionHandler)
	}

	override open func willActivate() {
		super.willActivate()
		printsWillActivate()
	}

	override open func willDisappear() {
		super.willDisappear()
		printsWillDisappear()
	}
}

#else // Production builds should just typealias so that we remove a layer in the class hierarchy

public typealias CoreUserNotificationInterfaceController = WKUserNotificationInterfaceController

#endif

#endif
