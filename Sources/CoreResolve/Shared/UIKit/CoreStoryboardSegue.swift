//
//  CoreStoryboardSegue.swift
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

#if canImport(UIKit) && !os(watchOS)

import ObjectiveC
import UIKit

/// Performs custom Modal segues and retains the `transitioningDelegate` so that it may be used for dismissal transitions
open class CoreStoryboardSegue: UIStoryboardSegue {
	
	/// Returns the transitioning delegate used by this segue (subclasses DO NOT need to call super)
	open var delegateForTransitioning: UIViewControllerTransitioningDelegate {
		// If it is already set in the destination (for example, if we present multiple times), let's use it
		guard let retVal = objc_getAssociatedObject(destination, &CoreStoryboardSegue.AssociatedObjectHandle) as? UIViewControllerTransitioningDelegate else {
			fatalError("Subclasses must implement this read-only property")
		}
		return retVal
	}
	
	/// Returns an optional wrapping viewController for the viewController being passed in
	open func viewController(wrapping viewController: UIViewController) -> UIViewController {
		return viewController
	}
	
	override open func perform() {
		let destinationViewController = viewController(wrapping: destination)
		destinationViewController.modalPresentationStyle = .custom
		if destinationViewController.transitioningDelegate == nil {
			// Get and save the transitioning delegate (so that we can use it for dismissal)
			let transitioningDelegate = delegateForTransitioning
			objc_setAssociatedObject(destinationViewController, &CoreStoryboardSegue.AssociatedObjectHandle, transitioningDelegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
			destinationViewController.transitioningDelegate = transitioningDelegate
		}
		// Now perform the segue transition
		source.present(destinationViewController, animated: true)
	}
	
	internal static var AssociatedObjectHandle: UInt8 = 0
}

#endif
