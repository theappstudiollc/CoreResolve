//
//  CoreSegueHandling.swift
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

import Foundation

public protocol CoreSegueDefinesIdentifiers {

	static var definedSegueIdentifiers: Set<String> { get }
}

/// Represents a storyboard segue handler
public protocol CoreSegueHandling: CoreSegueDefinesIdentifiers {

	/// A RawRepresentable type that represents a storyboard segue's identifier(s) (e.g. a String-based enum)
	associatedtype SegueIdentifier: RawRepresentable, CaseIterable where SegueIdentifier.RawValue: StringProtocol
}

public extension CoreSegueHandling where Self: ViewController, SegueIdentifier.RawValue == String {

	/// Performs a segue usinga CoreSegueHandling.SegueIdentifier
	///
	/// - Parameters:
	///   - identifier: The StoryboardSegue's identifier
	///   - sender: The initiating sender of the StoryboardSegue
	func performSegue(withIdentifier identifier: SegueIdentifier, sender: Any?) {
		performSegue(withIdentifier: identifier.rawValue, sender: sender)
	}

	/// Retrieves the CoreSegueHandling.SegueIdentifier from a StoryboardSegue, if the value is defined as an enum
	///
	/// - Parameter segue: The StoryboardSegue for which to get the SegueIdentifier
	/// - Returns: Returns a SegueIdentifier if successful, or nil if not
	func segueIdentifierForSegue(_ segue: StoryboardSegue) -> SegueIdentifier? {
		guard let identifier = segue.identifier else { return nil }
		return SegueIdentifier(rawValue: identifier)
	}
}

public extension CoreSegueDefinesIdentifiers where Self: ViewController & CoreSegueHandling, SegueIdentifier.RawValue == String {

	static var definedSegueIdentifiers: Set<String> {
		return Set(SegueIdentifier.allCases.map { $0.rawValue })
	}
}

#if DEBUG && !TARGET_INTERFACE_BUILDER && !targetEnvironment(simulator)

internal extension ViewController {

	func checkSegueSetup(for viewController: ViewController) {
		guard let definesIdentifiers = viewController as? CoreSegueDefinesIdentifiers else { return }
		let definedIdentifiers = type(of: definesIdentifiers).definedSegueIdentifiers
		checkSegueSetup(with: definedIdentifiers)
	}

	private func checkSegueSetup(with identifiers: Set<String>) {

		let storyboardMappings = storyboardIdentifiers()
		LogManager.segueHandling.debug("%{public}@ uses %{public}@ segue classes", "\(type(of: self))", "\(Set(storyboardMappings.values))")
		let configuredIdentifiers = Set(storyboardMappings.keys)
		let differences = configuredIdentifiers.symmetricDifference(identifiers)
		guard differences.count > 0 else {
			LogManager.segueHandling.debug("Identifiers for %{public}@ check out: %{public}@", "\(type(of: self))", "\(identifiers)")
			return
		}
		for difference in differences {
			if configuredIdentifiers.contains(difference) {
				// NOTE: This is possibly ok in some scenarios, like for a cell showing another ViewController
				LogManager.segueHandling.debug("%{public}@ does not define a SegueIdentifier for '%{public}@'", "\(type(of: self))", "\(difference)")
			}
			if identifiers.contains(difference) {
				LogManager.segueHandling.debug("Storyboard for %{public}@ does not define a segue with identifier '%{public}@'", "\(type(of: self))", "\(difference)")
			}
		}
		assert(false, "\(type(of: self)) has a mismatch of storyboard identifiers: \(differences)")
	}

	private func storyboardIdentifiers() -> [String : String] {
		// TODO: We can look at the class name and map to an enum of Show vs ShowDetail vs Present, etc.
		guard let segueTemplates = value(forKey: "storyboardSegueTemplates") as? [NSObject] else {
			return [:]
		}
		return Dictionary(uniqueKeysWithValues: segueTemplates.compactMap { template in
			// TODO: UIStoryboardUnwindSegueTemplate do not contain "identifier" for some reason
			guard let identifier = template.value(forKey: "identifier") as? String else {
				LogManager.segueHandling.debug("%{public}@ does not have an 'identifier'", "\(type(of: template))")
				return nil
			}
			return (identifier, "\(type(of: template))")
		})
	}
}

#endif

#endif
