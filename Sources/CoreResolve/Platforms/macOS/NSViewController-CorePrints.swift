//
//  NSViewController-CorePrints.swift
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

#if os(macOS) && DEBUG && !TARGET_INTERFACE_BUILDER && !targetEnvironment(simulator)

import AppKit

internal extension NSViewController {
	
	// MARK: - Functions for NSViewController overrides
	
	func printsRestoreState(with coder: NSCoder) {
		guard self is CorePrintsStateRestoration else { return }
		LogManager.stateRestoration.debug("%{public}@ restoreState(with: %{public}@)", debugDescription, "\(coder)")
	}

	func printsViewDidAppear() {
		guard self is CorePrintsViewLifecycle else { return }
		LogManager.viewLifecycle.debug("%{public}@ viewDidAppear()", debugDescription)
	}
	
	func printsViewDidDisappear() {
		guard self is CorePrintsViewLifecycle else { return }
		LogManager.viewLifecycle.debug("%{public}@ viewDidDisappear(), superview = %{public}@", debugDescription, printDescription(view: view.superview))
	}
	
	func printsViewDidLayout() {
		guard self is CorePrintsViewControllerLayout else { return }
		LogManager.viewControllerLayout.debug("%{public}@ viewDidLayout()", debugDescription)
	}

	func printsViewWillAppear() {
		guard self is CorePrintsViewLifecycle else { return }
		LogManager.viewLifecycle.debug("%{public}@ viewWillAppear(), superview = %{public}@", debugDescription, printDescription(view: view.superview))
	}
	
	func printsViewWillDisappear() {
		guard self is CorePrintsViewLifecycle else { return }
		LogManager.viewLifecycle.debug("%{public}@ viewWillDisappear()", debugDescription)
	}
	
	func printsViewWillLayout() {
		guard self is CorePrintsViewControllerLayout else { return }
		LogManager.viewControllerLayout.debug("%{public}@ viewWillLayout()", debugDescription)
	}

	func printsViewWillTransition(to size: NSSize) {
		guard self is CorePrintsViewControllerLayout else { return }
		LogManager.viewControllerLayout.debug("%{public}@ viewWillTransition(to: %{public}@)", debugDescription, "\(size)")
	}
}

#endif
