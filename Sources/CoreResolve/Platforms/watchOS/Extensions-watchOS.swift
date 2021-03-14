//
//  Extensions-watchOS.swift
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

#if os(watchOS)

import Foundation


/// Error describing the reason an extension method in `CoreResolve` has failed
///
/// - improperlyConfiguredBundle: The bundle is not properly configured. Populate the description with a description of the problem
public enum CoreResolveExtensionError: Error {

	case improperlyConfiguredBundle(_ problemDescription: String)
}

public extension Bundle {

	private static let nsExtensionKey = "NSExtension"
	private static let nsExtensionAttributesKey = "NSExtensionAttributes"
	private static let wkAppBundleIdentifierKey = "WKAppBundleIdentifier"

	/// Returns the `Bundle` for the companion Watch App. Only valid when called from a properly-configured WatchKit App extension
	class var watchAppBundle: Result<Bundle, Error> {
		guard let infoDictionary = Bundle.main.infoDictionary else {
			return .failure(CoreResolveExtensionError.improperlyConfiguredBundle("No InfoDictionary present in the `main` bundle"))
		}
		guard let extensionDictionary = infoDictionary[nsExtensionKey] as? [String : Any] else {
			return .failure(CoreResolveExtensionError.improperlyConfiguredBundle("`\(nsExtensionKey)` not present in `main` bundle's InfoDictionary"))
		}
		guard let extensionAttributes = extensionDictionary[nsExtensionAttributesKey] as? [String : Any] else {
			return .failure(CoreResolveExtensionError.improperlyConfiguredBundle("`\(nsExtensionKey).\(nsExtensionAttributesKey)` not present in `main` bundle's InfoDictionary"))
		}
		guard let appBundleIdentifier = extensionAttributes[wkAppBundleIdentifierKey] as? String else {
			return .failure(CoreResolveExtensionError.improperlyConfiguredBundle("`\(nsExtensionKey).\(nsExtensionAttributesKey).\(wkAppBundleIdentifierKey)` not present in `main` bundle's InfoDictionary"))
		}
		guard let bundle = Bundle(identifier: appBundleIdentifier) else {
			return .failure(CoreResolveExtensionError.improperlyConfiguredBundle("Bundle with identifier `\(appBundleIdentifier)` cannot be found"))
		}
		return .success(bundle)
	}
}

#endif
