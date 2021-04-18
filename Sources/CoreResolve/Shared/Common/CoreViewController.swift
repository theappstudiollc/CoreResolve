//
//  CoreViewController.swift
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

// NOTE: The order of these #if statements matter, in order to support all platforms + Interface Builder + deployment scenarios

#if os(watchOS)
import WatchKit
#elseif os(iOS) || os(tvOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

#if TARGET_INTERFACE_BUILDER || targetEnvironment(simulator)

#if os(watchOS)

open class CoreViewController: WKInterfaceController { }

#elseif os(iOS) || os(tvOS)

open class CoreViewController: UIViewController { }

#elseif os(macOS)

open class CoreViewController: NSViewController { }

#endif

#elseif DEBUG

/// Core view controller, that enables CorePrintsSupporting capabilities in DEBUG mode
open class CoreViewController: ViewController, CorePrintsSupporting {
	
	// MARK: - Common ViewController lifecycle events

	deinit {
		printsDeinit()
	}

	#if os(watchOS)

	public override init() {
		super.init()
		printsInit()
	}

	open override func awake(withContext context: Any?) {
		super.awake(withContext: context)
		printsAwakeWithContext(context)
	}

	open override func didAppear() {
		super.didAppear()
		printsDidAppear()
	}

	open override func didDeactivate() {
		super.didDeactivate()
		printsDidDeactivate()
	}

	open override func willActivate() {
		super.willActivate()
		printsWillActivate()
	}

	open override func willDisappear() {
		super.willDisappear()
		printsWillDisappear()
	}

	#else // Common to every platform except watchOS
	
	open override func awakeFromNib() {
		super.awakeFromNib()
		printsAwakeFromNib()
		checkSegueSetup(for: self)
	}
	
	open override func encodeRestorableState(with coder: NSCoder) {
		super.encodeRestorableState(with: coder)
		printsEncodeRestorableState(with: coder)
	}

	open override func restoreUserActivityState(_ activity: NSUserActivity) {
		super.restoreUserActivityState(activity)
		printsRestoreUserActivityState(activity)
	}

	open override func updateUserActivityState(_ activity: NSUserActivity) {
		super.updateUserActivityState(activity)
		printsUpdateUserActivityState(activity)
	}

	open override func viewDidLoad() {
		super.viewDidLoad()
		printsViewDidLoad()
	}

	#endif
	
	#if os(iOS) || os(tvOS)
	
	// MARK: - iOS & tvOS UIViewController lifecycle events
	
	open override func allowedChildrenForUnwinding(from source: UIStoryboardUnwindSegueSource) -> [UIViewController] {
		let retVal = super.allowedChildrenForUnwinding(from: source)
		printsAllowedChildViewControllersForUnwinding(from: source, retVal: retVal)
		return retVal
	}
	
	open override func applicationFinishedRestoringState() {
		super.applicationFinishedRestoringState()
		printsApplicationFinishedRestoringState()
	}

	@available(iOS 13.0, tvOS 13.0, *)
	open override func canPerformUnwindSegueAction(_ action: Selector, from fromViewController: UIViewController, sender: Any?) -> Bool {
		let retVal = super.canPerformUnwindSegueAction(action, from: fromViewController, sender: sender)
		printsCanPerformUnwindSegueAction(action, from: fromViewController, sender: sender, retVal: retVal)
		return retVal
	}

	@available(macCatalyst, deprecated: 13.0)
	open override func canPerformUnwindSegueAction(_ action: Selector, from fromViewController: UIViewController, withSender sender: Any) -> Bool {
		let retVal = super.canPerformUnwindSegueAction(action, from: fromViewController, withSender: sender)
		printsCanPerformUnwindSegueAction(action, from: fromViewController, withSender: sender, retVal: retVal)
		return retVal
	}

	open override func childContaining(_ source: UIStoryboardUnwindSegueSource) -> UIViewController? {
		let retVal = super.childContaining(source)
		printsChildContaining(source, retVal: retVal)
		return retVal
	}

	open override func collapseSecondaryViewController(_ secondaryViewController: UIViewController, for splitViewController: UISplitViewController) {
		super.collapseSecondaryViewController(secondaryViewController, for: splitViewController)
		printsCollapseSecondaryViewController(secondaryViewController, for: splitViewController)
	}

	open override func decodeRestorableState(with coder: NSCoder) {
		super.decodeRestorableState(with: coder)
		printsDecodeRestorableState(with: coder)
	}
	
	open override func didMove(toParent parent: UIViewController?) {
		super.didMove(toParent: parent)
		printsDidMove(toParent: parent)
	}
	
	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		printsInit(coder: aDecoder)
	}
	
	public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		printsInit(nibName: nibNameOrNil, bundle: nibBundleOrNil)
	}
	
	open override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		super.prepare(for: segue, sender: sender)
		printsPrepare(for: segue, sender: sender)
	}

	open override func separateSecondaryViewController(for splitViewController: UISplitViewController) -> UIViewController? {
		let retVal = super.separateSecondaryViewController(for: splitViewController)
		printsSeparateSecondaryViewController(for: splitViewController, retVal: retVal)
		return retVal
	}

	open override var shouldAutomaticallyForwardAppearanceMethods: Bool {
		let retVal = super.shouldAutomaticallyForwardAppearanceMethods
		printsShouldAutomaticallyForwardAppearanceMethods(retVal: retVal)
		return retVal
	}

	open override func targetViewController(forAction action: Selector, sender: Any?) -> UIViewController? {
		let retVal = super.targetViewController(forAction: action, sender: sender)
		printsTargetViewController(forAction: action, sender: sender, retVal: retVal)
		return retVal
	}

	open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		printsTraitCollectionDidChange(previousTraitCollection)
	}
	
	open override func unwind(for unwindSegue: UIStoryboardSegue, towards subsequentVC: UIViewController) {
		super.unwind(for: unwindSegue, towards: subsequentVC)
		printsUnwind(for: unwindSegue, towardsViewController: subsequentVC)
	}

	open override func updateViewConstraints() {
		super.updateViewConstraints()
		printsUpdateViewConstraints()
	}
	
	open override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		printsViewDidAppear(animated)
	}
	
	open override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		printsViewDidDisappear(animated)
	}
	
	open override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		printsViewDidLayoutSubviews()
	}
	
	@available(iOS 11.0, tvOS 11.0, *)
	open override func viewSafeAreaInsetsDidChange() {
		super.viewSafeAreaInsetsDidChange()
		printsViewSafeAreaInsetsDidChange()
	}
	
	open override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		printsViewWillAppear(animated)
	}
	
	open override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		printsViewWillDisappear(animated)
	}
	
	open override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		printsViewWillLayoutSubviews()
	}
	
	open override func willMove(toParent parent: UIViewController?) {
		super.willMove(toParent: parent)
		printsWillMove(toParent: parent)
	}
	
	open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		printsViewWillTransition(to: size, with: coordinator)
	}
	
	#elseif os(macOS)
	
	// MARK: - macOS NSViewController lifecycle events
	
	open override func restoreState(with coder: NSCoder) {
		super.restoreState(with: coder)
		printsRestoreState(with: coder)
	}

	open override func viewDidAppear() {
		super.viewDidAppear()
		printsViewDidAppear()
	}
	
	open override func viewDidDisappear() {
		super.viewDidDisappear()
		printsViewDidDisappear()
	}
	
	open override func viewDidLayout() {
		super.viewDidLayout()
		printsViewDidLayout()
	}
	
	open override func viewWillAppear() {
		super.viewWillAppear()
		printsViewWillAppear()
	}
	
	open override func viewWillDisappear() {
		super.viewWillDisappear()
		printsViewWillDisappear()
	}
	
	open override func viewWillLayout() {
		super.viewWillLayout()
		printsViewWillLayout()
	}
	
	open override func viewWillTransition(to newSize: NSSize) {
		super.viewWillTransition(to: newSize)
		printsViewWillTransition(to: newSize)
	}

	#endif
}

#else // Production builds should just typealias so that we remove a layer in the class hierarchy

public typealias CoreViewController = ViewController

#endif
