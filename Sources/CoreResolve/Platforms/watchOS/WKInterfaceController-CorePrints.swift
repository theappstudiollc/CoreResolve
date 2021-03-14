//
//  WKInterfaceController-CorePrints.swift
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

#if canImport(WatchKit) && DEBUG && !TARGET_INTERFACE_BUILDER && !targetEnvironment(simulator)

import UserNotifications
import WatchKit

internal extension WKInterfaceController {

	// MARK: - Functions for WKInterfaceController overrides

	func printsAwakeWithContext(_ context: Any?) {
		guard self is CorePrintsViewLifecycle else { return }
		LogManager.viewLifecycle.debug("%{public}@ awake(withContext: %{public}@)", debugDescription, printDescription(any: context))
	}

	func printsDidAppear() {
		guard self is CorePrintsViewLifecycle else { return }
		LogManager.viewLifecycle.debug("%{public}@ didAppear()", debugDescription)
	}

	func printsDidDeactivate() {
		guard self is CorePrintsViewLifecycle else { return }
		LogManager.viewLifecycle.debug("%{public}@ didDeactivate()", debugDescription)
	}

	func printsInit() {
		guard self is CorePrintsViewLifecycle else { return }
		LogManager.viewLifecycle.debug("%{public}@ init()", debugDescription)
	}

	@available(watchOS 5.0, *)
	func printsDidReceive(_ notification: UNNotification) {
		guard self is CorePrintsViewLifecycle else { return }
		LogManager.viewLifecycle.debug("%{public}@ didReceive(%{public}@)", debugDescription, printDescription(any: notification))
	}

	@available(watchOS 3.0, *)
	func printsDidReceive(_ notification: UNNotification, withCompletion completionHandler: @escaping (WKUserNotificationInterfaceType) -> Swift.Void) {
		guard self is CorePrintsViewLifecycle else { return }
		LogManager.viewLifecycle.debug("%{public}@ didReceive(%{public}@), withCompletion: <completion>", debugDescription, printDescription(any: notification))
	}

	func printsWillActivate() {
		guard self is CorePrintsViewLifecycle else { return }
		LogManager.viewLifecycle.debug("%{public}@ willActivate()", debugDescription)
	}

	func printsWillDisappear() {
		guard self is CorePrintsViewLifecycle else { return }
		LogManager.viewLifecycle.debug("%{public}@ willDisappear()", debugDescription)
	}
}

#endif
