//
//  CoreCollectionViewController.swift
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

#if os(iOS) || os(tvOS)

import UIKit

#if TARGET_INTERFACE_BUILDER || targetEnvironment(simulator)
// Typealias doesn't work well with Interface Builder, and for Unit Testing we do not want any CorePrints

open class CoreCollectionViewController: UICollectionViewController { }

#elseif DEBUG

open class CoreCollectionViewController: UICollectionViewController, CorePrintsSupporting {
	
	deinit {
		printsDeinit()
	}
	
	override open func allowedChildrenForUnwinding(from source: UIStoryboardUnwindSegueSource) -> [UIViewController] {
		let retVal = super.allowedChildrenForUnwinding(from: source)
		printsAllowedChildViewControllersForUnwinding(from: source, retVal: retVal)
		return retVal
	}
	
	override open func applicationFinishedRestoringState() {
		super.applicationFinishedRestoringState()
		printsApplicationFinishedRestoringState()
	}

	override open func awakeFromNib() {
		super.awakeFromNib()
		printsAwakeFromNib()
		checkSegueSetup(for: self)
	}

	@available(iOS 13.0, tvOS 13.0, *)
	override open func canPerformUnwindSegueAction(_ action: Selector, from fromViewController: UIViewController, sender: Any?) -> Bool {
		let retVal = super.canPerformUnwindSegueAction(action, from: fromViewController, sender: sender)
		printsCanPerformUnwindSegueAction(action, from: fromViewController, sender: sender, retVal: retVal)
		return retVal
	}

	@available(macCatalyst, deprecated: 13.0)
	override open func canPerformUnwindSegueAction(_ action: Selector, from fromViewController: UIViewController, withSender sender: Any) -> Bool {
		let retVal = super.canPerformUnwindSegueAction(action, from: fromViewController, withSender: sender)
		printsCanPerformUnwindSegueAction(action, from: fromViewController, withSender: sender, retVal: retVal)
		return retVal
	}

	override open func childContaining(_ source: UIStoryboardUnwindSegueSource) -> UIViewController? {
		let retVal = super.childContaining(source)
		printsChildContaining(source, retVal: retVal)
		return retVal
	}

	override open func collapseSecondaryViewController(_ secondaryViewController: UIViewController, for splitViewController: UISplitViewController) {
		super.collapseSecondaryViewController(secondaryViewController, for: splitViewController)
		printsCollapseSecondaryViewController(secondaryViewController, for: splitViewController)
	}

	override open func decodeRestorableState(with coder: NSCoder) {
		super.decodeRestorableState(with: coder)
		printsDecodeRestorableState(with: coder)
	}
	
	override open func didMove(toParent parent: UIViewController?) {
		super.didMove(toParent: parent)
		printsDidMove(toParent: parent)
	}
	
	override open func encodeRestorableState(with coder: NSCoder) {
		super.encodeRestorableState(with: coder)
		printsEncodeRestorableState(with: coder)
	}
	
	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		printsInit(coder: aDecoder)
	}
	
	override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		printsInit(nibName: nibNameOrNil, bundle: nibBundleOrNil)
	}
	
	override public init(collectionViewLayout layout: UICollectionViewLayout) {
		super.init(collectionViewLayout: layout)
		guard self is CorePrintsViewLifecycle else { return }
		LogManager.viewLifecycle.debug("%{public}@ init(collectionViewLayout: %{public}@)", debugDescription, "\(layout)")
	}
	
	override open func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		super.prepare(for: segue, sender: sender)
		printsPrepare(for: segue, sender: sender)
	}

	override open func restoreUserActivityState(_ activity: NSUserActivity) {
		super.restoreUserActivityState(activity)
		printsRestoreUserActivityState(activity)
	}

	override open func separateSecondaryViewController(for splitViewController: UISplitViewController) -> UIViewController? {
		let retVal = super.separateSecondaryViewController(for: splitViewController)
		printsSeparateSecondaryViewController(for: splitViewController, retVal: retVal)
		return retVal
	}

	override open func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		printsTraitCollectionDidChange(previousTraitCollection)
	}
	
	override open func unwind(for unwindSegue: UIStoryboardSegue, towards subsequentVC: UIViewController) {
		super.unwind(for: unwindSegue, towards: subsequentVC)
		printsUnwind(for: unwindSegue, towardsViewController: subsequentVC)
	}

	override open func updateUserActivityState(_ activity: NSUserActivity) {
		super.updateUserActivityState(activity)
		printsUpdateUserActivityState(activity)
	}

	override open func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		printsViewDidAppear(animated)
	}
	
	override open func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		printsViewDidDisappear(animated)
	}
	
	override open func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		printsViewDidLayoutSubviews()
	}
	
	override open func viewDidLoad() {
		super.viewDidLoad()
		printsViewDidLoad()
	}
	
	@available(iOS 11.0, tvOS 11.0, *)
	override open func viewSafeAreaInsetsDidChange() {
		super.viewSafeAreaInsetsDidChange()
		printsViewSafeAreaInsetsDidChange()
	}
	
	override open func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		printsViewWillAppear(animated)
	}
	
	override open func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		printsViewWillDisappear(animated)
	}
	
	override open func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		printsViewWillLayoutSubviews()
	}
	
	override open func willMove(toParent parent: UIViewController?) {
		super.willMove(toParent: parent)
		printsWillMove(toParent: parent)
	}
	
	override open func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		printsViewWillTransition(to: size, with: coordinator)
	}
}

#else // Production builds should just typealias so that we remove a layer in the class hierarchy

public typealias CoreCollectionViewController = UICollectionViewController

#endif

#elseif os(macOS)

// macOS CoreCollectionViewController are really ViewControllers with collectionView and collectionScrollView outlets

import AppKit

open class CoreCollectionViewController: CoreViewController {
	
	@IBOutlet public var collectionScrollView: NSScrollView!
	@IBOutlet public var collectionView: NSCollectionView!
}

#endif
