//
//  UIViewController-CorePrints.swift
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

#if canImport(UIKit) && !os(watchOS) && DEBUG && !TARGET_INTERFACE_BUILDER && !targetEnvironment(simulator)

import UIKit

internal extension UIViewController {

	// MARK: - Functions for UIViewController overrides

	func printDescription(traitCollection: UITraitCollection?) -> String {
		guard let traitCollection = traitCollection else { return "<nil>" }
		return traitCollection.debugDescription
	}

	func printsAllowedChildViewControllersForUnwinding(from source: UIStoryboardUnwindSegueSource, retVal: [UIViewController]) {
		guard self is CorePrintsSegueHandling else { return }
		LogManager.segueHandling.debug("%{public}@ allowedChildViewControllersForUnwinding(from: %{public}@) = %{public}@", debugDescription, "\(source)", "\(retVal)")
	}
	
	func printsApplicationFinishedRestoringState() {
		guard self is CorePrintsStateRestoration else { return }
		LogManager.stateRestoration.debug("%{public}@ applicationFinishedRestoringState()", debugDescription)
	}

	func printsCanPerformUnwindSegueAction(_ action: Selector, from fromViewController: UIViewController, sender: Any?, retVal: Bool) {
		guard self is CorePrintsSegueHandling else { return }
		LogManager.segueHandling.debug("%{public}@ canPerformUnwindSegueAction(%{public}@, from: %{public}@, sender: %{public}@) = %d", debugDescription, "\(action)", printDescription(viewController: fromViewController), printDescription(any: sender), retVal)
	}

	func printsCanPerformUnwindSegueAction(_ action: Selector, from fromViewController: UIViewController, withSender sender: Any, retVal: Bool) {
		guard self is CorePrintsSegueHandling else { return }
		LogManager.segueHandling.debug("%{public}@ canPerformUnwindSegueAction(%{public}@, from: %{public}@, withSender: %{public}@) = %d", debugDescription, "\(action)", printDescription(viewController: fromViewController), printDescription(any: sender), retVal)
	}

	func printsChildContaining(_ source: UIStoryboardUnwindSegueSource, retVal: UIViewController?) {
		guard self is CorePrintsSegueHandling else { return }
		LogManager.segueHandling.debug("%{public}@ childContaining(%{public}@) = %{public}@", debugDescription, "\(source)", printDescription(viewController: retVal))
	}

	func printsCollapseSecondaryViewController(_ secondaryViewController: UIViewController, for splitViewController: UISplitViewController) {
		guard self is CorePrintsViewControllerLayout else { return }
		LogManager.viewControllerLayout.debug("%{public}@ collapseSecondaryViewController(%{public}@, for: %{public}@)", debugDescription, secondaryViewController.debugDescription, splitViewController.debugDescription)
	}

	func printsDecodeRestorableState(with coder: NSCoder) {
		guard self is CorePrintsStateRestoration else { return }
		LogManager.stateRestoration.debug("%{public}@ decodeRestorableState(with: %{public}@)", debugDescription, "\(coder)")
	}
	
	func printsDidMove(toParent parent: UIViewController?) {
		guard self is CorePrintsViewLifecycle else { return }
		LogManager.viewLifecycle.debug("%{public}@ didMove(toParent: %{public}@)", debugDescription, printDescription(viewController: parent))
	}
	
	func printsInit(coder aDecoder: NSCoder) {
		guard self is CorePrintsViewLifecycle else { return }
		LogManager.viewLifecycle.debug("%{public}@ init(coder: %{public}@)", debugDescription, "\(aDecoder)")
	}
	
	func printsInit(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		guard self is CorePrintsViewLifecycle else { return }
		LogManager.viewLifecycle.debug("%{public}@ init(nibName: %{public}@,  bundle: %{public}@)", debugDescription, String(describing: nibNameOrNil), String(describing: nibBundleOrNil))
	}
	
	func printsPrepare(for segue: UIStoryboardSegue, sender: Any?) {
		guard self is CorePrintsSegueHandling else { return }
		LogManager.segueHandling.debug("%{public}@ prepare(for: %{public}@, sender: %{public}@)", debugDescription, "\(segue)", printDescription(any: sender))
	}

	func printsSeparateSecondaryViewController(for splitViewController: UISplitViewController, retVal: UIViewController?) {
		guard self is CorePrintsViewControllerLayout else { return }
		LogManager.viewControllerLayout.debug("%{public}@ separateSecondaryViewController(for: %{public}@) = %{public}@", debugDescription, splitViewController.debugDescription, printDescription(viewController: retVal))
	}

	func printsShouldAutomaticallyForwardAppearanceMethods(retVal: Bool) {
		guard self is CorePrintsViewLifecycle else { return }
		LogManager.viewLifecycle.debug("%{public}@ shouldAutomaticallyForwardAppearanceMethods = %d", debugDescription, retVal)
	}

	func printsTargetViewController(forAction action: Selector, sender: Any?, retVal: UIViewController?) {
		guard self is CorePrintsSegueHandling else { return }
		LogManager.segueHandling.debug("%{public}@ targetViewController(forAction: %{public}@, sender: %{public}@) = %{public}@", debugDescription, "\(action)", printDescription(any: sender), printDescription(viewController: retVal))
	}

	func printsTraitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		guard self is CorePrintsViewControllerLayout else { return }
		LogManager.viewControllerLayout.debug("%{public}@ traitCollectionDidChange(from: %{public}@) to: %{public}@", debugDescription, printDescription(traitCollection: previousTraitCollection), printDescription(traitCollection: traitCollection))
	}
	
	func printsUnwind(for unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
		guard self is CorePrintsSegueHandling else { return }
		LogManager.segueHandling.debug("%{public}@ unwind(for: %{public}@, towardsViewController: %{public}@)", debugDescription, unwindSegue, printDescription(viewController: subsequentVC))
	}
	
	func printsUpdateViewConstraints() {
		guard self is CorePrintsViewLifecycle else { return }
		LogManager.viewLifecycle.debug("%{public}@ updateViewConstraints()", debugDescription)
	}
	
	func printsViewDidAppear(_ animated: Bool) {
		guard self is CorePrintsViewLifecycle else { return }
		LogManager.viewLifecycle.debug("%{public}@ viewDidAppear(%d)\n\t[isBeingPresented = %d, isMovingToParentViewController = %d]", debugDescription, animated, isBeingPresented, isMovingToParent)
	}
	
	func printsViewDidDisappear(_ animated: Bool) {
		guard self is CorePrintsViewLifecycle else { return }
		LogManager.viewLifecycle.debug("%{public}@ viewDidDisappear(%d)\n\t[isBeingDismissed = %d, isMovingFromParentViewController = %d, superview = %{public}@]", debugDescription, animated, isBeingDismissed, isMovingFromParent, printDescription(view: view.superview))
	}
	
	func printsViewDidLayoutSubviews() {
		guard self is CorePrintsViewControllerLayout else { return }
		LogManager.viewControllerLayout.debug("%{public}@ viewDidLayoutSubviews()", debugDescription)
	}
	
	@available(iOS 11.0, tvOS 11.0, *)
	func printsViewSafeAreaInsetsDidChange() {
		guard self is CorePrintsViewControllerLayout else { return }
		LogManager.viewControllerLayout.debug("%{public}@ viewSafeAreaInsetsDidChange = %{public}@ => %{public}@", debugDescription, "\(additionalSafeAreaInsets)", "\(view.safeAreaInsets)")
	}
	
	func printsViewWillAppear(_ animated: Bool) {
		guard self is CorePrintsViewLifecycle else { return }
		LogManager.viewLifecycle.debug("%{public}@ viewWillAppear(%d)\n\t[isBeingPresented = %d, isMovingToParentViewController = %d, superview = %{public}@]", debugDescription, animated, isBeingPresented, isMovingToParent, printDescription(view: view.superview))
	}
	
	func printsViewWillDisappear(_ animated: Bool) {
		guard self is CorePrintsViewLifecycle else { return }
		LogManager.viewLifecycle.debug("%{public}@ viewWillDisappear(%d)\n\t[isBeingDismissed = %d, isMovingFromParentViewController = %d]", debugDescription, animated, isBeingDismissed, isMovingFromParent)
	}
	
	func printsViewWillLayoutSubviews() {
		guard self is CorePrintsViewControllerLayout else { return }
		LogManager.viewControllerLayout.debug("%{public}@ viewWillLayoutSubviews()", debugDescription)
	}
	
	func printsWillMove(toParent parent: UIViewController?) {
		guard self is CorePrintsViewLifecycle else { return }
		if isViewLoaded {
			LogManager.viewLifecycle.debug("%{public}@ willMove(toParent: %{public}@)\n\t[superview = %{public}@]", debugDescription, printDescription(viewController: parent), printDescription(view: view.superview))
		} else {
			LogManager.viewLifecycle.debug("%{public}@ willMove(toParent: %{public}@)", debugDescription, printDescription(viewController: parent))
		}
	}
	
	func printsViewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		guard self is CorePrintsViewControllerLayout else { return }
		LogManager.viewControllerLayout.debug("%{public}@ viewWillTransition(to: %{public}@, with: %{public}@)", debugDescription, "\(size)", "\(coordinator)")
	}
}

#endif
