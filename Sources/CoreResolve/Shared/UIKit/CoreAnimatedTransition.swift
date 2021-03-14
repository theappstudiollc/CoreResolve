//
//  CoreAnimatedTransition.swift
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

open class CoreAnimatedTransition: NSObject {
	
	public private(set) var isPresenting: Bool
	public private(set) var removesPresentersView: Bool

	open func animateDismissal(with transitionContext: UIViewControllerContextTransitioning) {
		fatalError("Subclasses must implement this function")
	}
	
	open func animatePresentation(with transitionContext: UIViewControllerContextTransitioning) {
		fatalError("Subclasses must implement this function")
	}
	
	public init(asPresenting presenting: Bool, removesPresentersView: Bool = true) {
		self.isPresenting = presenting
		self.removesPresentersView = removesPresentersView
		super.init()
	}
	
	internal weak var fromViewController: UIViewController? = nil
	internal var isAnimating: Bool = false
	internal weak var toViewController: UIViewController? = nil
}

extension CoreAnimatedTransition: UIViewControllerAnimatedTransitioning {
	
	public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		// Save some values from the transitionContext
		isAnimating = transitionContext.isAnimated
		fromViewController = transitionContext.viewController(forKey: .from)
		toViewController = transitionContext.viewController(forKey: .to)
		
		if isPresenting { // We cannot depend on toViewController's isBeingPresented
			if removesPresentersView {
				fromViewController?.beginAppearanceTransition(false, animated: isAnimating)
			}
			animatePresentation(with: transitionContext)
		} else {
			if removesPresentersView {
				toViewController?.beginAppearanceTransition(true, animated: isAnimating)
			}
			animateDismissal(with: transitionContext)
		}
	}
	
	public func animationEnded(_ transitionCompleted: Bool) {
		if !transitionCompleted {
			// Transition was cancelled. Update view lifecycle
			if isPresenting {
				// If this is a cancelled presentation, clean up
				if removesPresentersView {
					fromViewController?.beginAppearanceTransition(true, animated: isAnimating)
				}
				if let toViewController = toViewController {
					objc_setAssociatedObject(toViewController, &CoreStoryboardSegue.AssociatedObjectHandle, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
				}
			} else {
				toViewController?.beginAppearanceTransition(false, animated: isAnimating)
			}
		}
		// Complete view lifecycle
		if isPresenting {
			if removesPresentersView {
				fromViewController?.endAppearanceTransition()
			}
		} else {
			toViewController?.endAppearanceTransition()
		}
		fromViewController = nil
		toViewController = nil
	}
	
	open func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		fatalError("Subclasses must implement this function")
	}
}

#endif
