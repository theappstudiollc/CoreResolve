//
//  CorePrints.swift
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

/// Protocol that defines whether the UI viewcontroller supports CorePrints
public protocol CorePrintsSupporting { }

/// Protocol that defines whether ViewController layout is printed to the debug console
public protocol CorePrintsViewControllerLayout: CorePrintsSupporting { }

/// Protocol that defines whether Segue handling is printed to the debug console
public protocol CorePrintsSegueHandling: CorePrintsSupporting { }

/// Protocol that defines whether UI State Restoration or NSUserActivity-based updates are printed to the debug console
public protocol CorePrintsStateRestoration: CorePrintsSupporting { }

/// Protocol that defines whether View lifecycle is printed to the debug console
public protocol CorePrintsViewLifecycle: CorePrintsSupporting { }

/// Protocol that defines whether all events are printed to the debug console
public protocol CorePrintsAllEvents: CorePrintsViewControllerLayout, CorePrintsSegueHandling, CorePrintsStateRestoration, CorePrintsViewLifecycle { }

// MARK: - CorePrintsSupporting for ViewController

#if DEBUG && !TARGET_INTERFACE_BUILDER && !targetEnvironment(simulator)

import Foundation
import os.log

internal extension LogManager {

	static var segueHandling = LogManager(configurationProvider: LogManagerConfigurationProvider(bundle: .main, category: "SegueHandling"))
	static var stateRestoration = LogManager(configurationProvider: LogManagerConfigurationProvider(bundle: .main, category: "StateRestoration"))
	static var viewControllerLayout = LogManager(configurationProvider: LogManagerConfigurationProvider(bundle: .main, category: "ViewControllerLayout"))
	static var viewLifecycle = LogManager(configurationProvider: LogManagerConfigurationProvider(bundle: .main, category: "ViewLifecycle"))
}

internal extension ViewController {
	
	// MARK: - Print helper functions
	
	func printsAwakeFromNib() {
		guard self is CorePrintsViewLifecycle else { return }
		LogManager.viewLifecycle.debug("%{public}@ awakeFromNib()", debugDescription)
	}

	func printDescription(any: Any?) -> String {
		guard let any = any else { return "<nil>" }
		guard let anyCustomDebugStringConvertible = any as? CustomDebugStringConvertible else { return "\(any)" }
		return anyCustomDebugStringConvertible.debugDescription
	}

	func printDescription(userActivity: NSUserActivity) -> String {
		return "\(userActivity.activityType)[\(String(describing: userActivity.userInfo))]"
	}

	#if os(iOS) || os(macOS) || os(tvOS)
	func printDescription(view: View?) -> String {
		guard let view = view else { return "<nil>" }
		return "\(type(of: view))\(view.frame)"
	}
	#endif

	func printDescription(viewController: ViewController?) -> String {
		guard let viewController = viewController else { return "<nil>" }
		return viewController.debugDescription
	}

	func printsDeinit() {
		guard self is CorePrintsViewLifecycle else { return }
		LogManager.viewLifecycle.debug("%{public}@ deinit", debugDescription)
	}

	#if !os(watchOS) // Every platform except watchOS

	func printsEncodeRestorableState(with coder: NSCoder) {
		guard self is CorePrintsStateRestoration else { return }
		LogManager.stateRestoration.debug("%{public}@ encodeRestorableState(with: %{public}@)", debugDescription, "\(coder)")
	}

	func printsRestoreUserActivityState(_ activity: NSUserActivity) {
		guard self is CorePrintsStateRestoration else { return }
		LogManager.stateRestoration.debug("%{public}@ restoreUserActivityState(%{public}@)", debugDescription, printDescription(userActivity: activity))
	}

	func printsUpdateUserActivityState(_ activity: NSUserActivity) {
		guard self is CorePrintsStateRestoration else { return }
		LogManager.stateRestoration.debug("%{public}@ updateUserActivityState(%{public}@)", debugDescription, printDescription(userActivity: activity))
	}

	func printsViewDidLoad() {
		guard self is CorePrintsViewLifecycle else { return }
		LogManager.viewLifecycle.debug("%{public}@ viewDidLoad()\n\t[parent = %{public}@]", debugDescription, printDescription(viewController: parent))
	}

	#endif
}

#endif
