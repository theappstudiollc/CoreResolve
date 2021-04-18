//
//  CoreContainerViewController.swift
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

#if !os(watchOS)

#if os(iOS) || os(tvOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

/// A base ContainerViewController supporting multiple kinds of containment use cases
open class CoreContainerViewController: CoreViewController {
	
	// MARK: - Public properties and methods
    
    /// The currently active child ViewController
	public var activeChild: ViewController? {
		get { return _activeChild }
		set { try! setActiveChild(newValue, animation: defaultAnimation) }
	}
	
	/// The `CoreLayoutAnchorable` to bound the activeChild. Defaults to the view. Subclasses may return a custom layout guide or view
	open var activeChildLayoutAnchorable: CoreLayoutAnchorable {
		return view
	}
	
    /// The animation transition duration when setting a new activeChild
	open var activeChildTransitionDuration: TimeInterval {
		get { return 0.2 }
	}

    /// Animation to use when transitioning to a new activeChild
    ///
    /// - animated: The transition should animate with the specified duration. Note, the animation API will still be used even if the duration is less-than or equal-to zero, which means that the completion handler is escaping
    /// - assignOnly: Assigns an existing or upcoming child to the `activeChild` property. Typically used for embed segues. Requires that the existing value of `activeChild` is nil
    /// - notAnimated: The transition should not animate. You may assume that the completion handler will not escape
    /// - withTransitionCoordinator: The transition to occur alongside an existing transition using the provided transition coordinator
	public enum Animation {
		case animated(duration: TimeInterval)
		case assignOnly
		case notAnimated
		#if os (iOS) || os(tvOS)
		case withTransitionCoordinator(coordinator: UIViewControllerTransitionCoordinator)
		#endif
	}
	
    /// Sets a new activeChild using the provided AnimationOptions
    ///
    /// - Parameters:
    ///   - activeChild: The new activeChild instance
    ///   - animation: The Animation that should be used in the transition
    ///   - completion: A completion closure when the transition is complete
    /// - Returns: Returns whether the animations are successfully queued to run
	@discardableResult open func setActiveChild(_ activeChild: ViewController?, animation: Animation, completion: (() -> Void)? = nil) throws -> Bool {
		
		guard _activeChild !== activeChild else {
			completion?()
			return false
		}
		
		switch animation {
		case .assignOnly:
			guard _activeChild == nil else { throw CoreContainerViewControllerError.unsupportedState }
			_activeChild = activeChild
			return false
		default:
			break
		}

		let deactivatingChild = _activeChild

		#if os(iOS) || os(tvOS)
		// ViewController lifecycle for children mimics that of a UIViewController pushed and popped in a UINavigationController
		manualAppearanceHandling = view.window != nil
		// Let the outgoing ViewController know first that it's about to be replaced by another
		deactivatingChild?.willMove(toParent: nil)
		#endif
		
		_activeChild = activeChild
		if let activeChild = activeChild {
			// Prepare the incoming ViewController for the transition
			if activeChild.parent !== self {
				addChild(activeChild)
			}
			// viewDidLoad() should happen below. If not, someone has prematurely read .view
			activeChild.view.alpha = 0
			activeChild.view.frame = activeChildLayoutAnchorable.layoutFrame
			if let containerView = activeChildLayoutAnchorable as? View {
				// Ensure the child's frame resizes with the container
				activeChild.view.autoresizingMask = .scalesWithParent
				activeChild.view.translatesAutoresizingMaskIntoConstraints = true
				containerView.addSubview(activeChild.view)
			} else {
				// Ensure the child's frame resizes with the activeChildLayoutGuide
				activeChild.view.translatesAutoresizingMaskIntoConstraints = false
				view.addSubview(activeChild.view)
				NSLayoutConstraint.activate(activeChild.view.constrain(to: activeChildLayoutAnchorable))
			}
		}
		
		#if os(iOS) || os(tvOS)
		if manualAppearanceHandling {
			deactivatingChild?.beginAppearanceTransition(false, animated: animation.isAnimated)
			activeChild?.beginAppearanceTransition(true, animated: animation.isAnimated)
		}
		#endif

		let animations = { (_: Any?) in
			#if os(iOS) || os(tvOS)
			activeChild?.view.alpha = 1
			deactivatingChild?.view.alpha = 0
			#else
			activeChild?.view.animator().alphaValue = 1
			deactivatingChild?.view.animator().alphaValue = 0
			#endif
		}

		let animationCompletion = { (_: Any?) in
			// Complete the transition for the outgoing ViewController
			deactivatingChild?.view.removeFromSuperview()
			#if os(iOS) || os(tvOS)
			if self.manualAppearanceHandling {
				deactivatingChild?.endAppearanceTransition()
			}
			#endif
			deactivatingChild?.removeFromParent()
			// Give the incoming ViewController the last say in this transition
			#if os(iOS) || os(tvOS)
			if self.manualAppearanceHandling {
				activeChild?.endAppearanceTransition()
			}
			activeChild?.didMove(toParent: self)
			self.manualAppearanceHandling = false
			#endif
			completion?()
		}

		switch animation {
		case .animated(let duration):
			#if os(iOS) || os(tvOS)
			UIView.animate(withDuration: max(0, duration), animations: { animations(nil) }, completion: animationCompletion)
			#else
			NSAnimationContext.runAnimationGroup({ context in
				context.duration = max(0, duration)
				animations(nil)
			}, completionHandler: { animationCompletion(nil) })
			#endif
			
		case .assignOnly:
			throw CoreContainerViewControllerError.unsupportedState
			
		case .notAnimated:
			animations(nil)
			animationCompletion(nil)
			
		#if os(iOS) || os(tvOS)
		case .withTransitionCoordinator(let transitionCoordinator):
			return transitionCoordinator.animate(alongsideTransition: animations, completion: animationCompletion)
		#endif
		}
		return true
	}
    
    // MARK: - CoreViewController overrides
	
	#if os(iOS) || os(tvOS)
    
    var manualAppearanceHandling = false
    open override var shouldAutomaticallyForwardAppearanceMethods: Bool {
        return !manualAppearanceHandling
    }
	
	#endif
	
    // MARK: - Private properties and methods
    
    var _activeChild: ViewController?
	
	var defaultAnimation: Animation {
		#if os(iOS) || os(tvOS)
		// For show segues, the `Animated` checkmark in Interface Builder affects UIView.areAnimationsEnabled
		return UIView.areAnimationsEnabled ? .animated(duration: activeChildTransitionDuration) : .notAnimated
		#else
		return .animated(duration: activeChildTransitionDuration)
		#endif
	}
}

extension CoreContainerViewController.Animation {
	
	public var animationDuration: TimeInterval {
		switch self {
		case .animated(let duration): return duration
		case .assignOnly: return 0
		case .notAnimated: return 0
			
		#if os(iOS) || os(tvOS)
		case .withTransitionCoordinator(let coordinator): return coordinator.transitionDuration
		#endif
		}
	}
	
	public var isAnimated: Bool {
		switch self {
		case .animated(_): return true
		case .assignOnly: return false
		case .notAnimated: return false
			
		#if os(iOS) || os(tvOS)
		case .withTransitionCoordinator(let coordinator): return coordinator.isAnimated
		#endif
		}
	}
}

#endif
