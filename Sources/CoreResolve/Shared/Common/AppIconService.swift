//
//  AppIconService.swift
//  CoreResolve
//
//  Created by David Mitchell
//  Copyright © 2021 The App Studio LLC.
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

import UIKit

// TODO: Add macOS support, which basically allows us to set any NSImage we desire (but define a provider)

public enum AppIcon: Equatable {
	case `default`
	case alternate(_ name: String)
}

/// Provides the ability to manage Application Icons
public protocol AppIconService {

	/// The configured alternate icons as specified in the bundle
	var alternateIconNames: [String] { get }

	var currentAppIcon: AppIcon { get }

	/// Sets the app icon to the type specified
	/// - Parameters:
	///   - appIcon: The `AppIcon` to set
	///   - completion: A completion handler returning whether there is a failure or success setting the app's icon
	func setAppIcon(_ appIcon: AppIcon, completion: @escaping (Result<Void, Error>) -> Void)

	/// Returns the `Image` for the specified `AppIcon`
	/// - Parameter appIcon: The `AppIcon` for which the image is desired
	func image(for appIcon: AppIcon) throws -> Image
}

/// Manages the Alternate Icons for an app by mapping an Int-based AppIcon to the CFBundleAlternateIcons defined in the app's bundle info dictionary
public class AppIconManager: AppIconService {

	public let application: UIApplication
	public let bundle: Bundle
	public let defaultIconName: String?

	public let alternateIconNames: [String]

	public var currentAppIcon: AppIcon {
		#if targetEnvironment(macCatalyst)
		return .default
		#else
		guard #available(iOS 10.3, tvOS 10.2, *) else { return .default }
		switch application.alternateIconName {
		case .none: return .default
		case .some(let name): return .alternate(name)
		}
		#endif
	}

	public func setAppIcon(_ appIcon: AppIcon, completion: @escaping (Result<Void, Error>) -> Void) {
		#if targetEnvironment(macCatalyst)
		fatalError()
		#else
		guard #available(iOS 10.3, tvOS 10.2, *), application.supportsAlternateIcons, alternateIconNames.count > 0 else {
			fatalError()
		}
		let nextIconName: String?
		switch appIcon {
		case .default: nextIconName = nil
		case .alternate(let name): nextIconName = name
		}
		application.setAlternateIconName(nextIconName) { error in
			if let error = error {
				completion(.failure(error))
			} else {
				completion(.success(()))
			}
		}
		#endif
	}

	public func image(for appIcon: AppIcon) throws -> Image {
		switch appIcon {
		case .default:
			guard let defaultIconName = defaultIconName, let image = UIImage(named: defaultIconName) else {
				fatalError()
			}
			return image
		case .alternate(let name):
			guard let image = Image(named: name, in: bundle, compatibleWith: nil) else {
				fatalError()
			}
			return image
		}
	}

	public init(with application: Application, in bundle: Bundle = .main) {
		self.application = application
		self.bundle = bundle
		guard let bundleIcons = bundle.infoDictionary?["CFBundleIcons"] as? [String : Any] else {
			alternateIconNames = []
			defaultIconName = nil
			return
		}
		if
			let primaryIconDictionary = bundleIcons["CFBundlePrimaryIcon"] as? [String : Any],
			let primaryIcons = primaryIconDictionary["CFBundleIconFiles"] as? [String] {
			defaultIconName = primaryIcons.last
		} else {
			defaultIconName = nil
		}
		if let alternateIconsDictionary = bundleIcons["CFBundleAlternateIcons"] as? [String : Any] {
			alternateIconNames = alternateIconsDictionary.keys.map { $0 }
		} else {
			alternateIconNames = []
		}
	}
}

#endif
