//
//  CoreUserActivityService.swift
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

import Foundation

/// Provides access to app-specific User Activities
public protocol CoreUserActivityService {

	/// An app-specific type that will map to the String-based user activities as defined in an app's bundle info dictionary
	associatedtype ActivityType: RawRepresentable

	/// Returns the app-specific `ActivityType` for the provided String identifier, if present. Otherwise it returns nil
	/// - Parameter identifier: The String identifier as defined in the app's bundle info dictionary
	func activityType(with identifier: String) -> ActivityType?

	/// Returns the configured `NSUserActivity` for the provided app-specific `ActivityType`
	/// - Parameter activityType: The app-specific `ActivityType`
	func userActivity(for activityType: ActivityType) -> NSUserActivity
}

/// Manages the User Activities for an app by mapping an Int-based ActivityType to the NSUserActivity strings defined in the app's bundle info dictionary
open class CoreUserActivityManager<ActivityType>: CoreUserActivityService where ActivityType: RawRepresentable, ActivityType.RawValue == Int {

	public let identifiers: [String]

	/// Returns the app-specific `ActivityType` for the provided String identifier, if present. Otherwise it returns nil
	/// - Parameter identifier: The String identifier as defined in the app's bundle info dictionary
	open func activityType(with identifier: String) -> ActivityType? {
		guard let index = identifiers.firstIndex(of: identifier) else { return nil }
		return ActivityType(rawValue: index)
	}

	/// Returns the configured `NSUserActivity` for the provided app-specific `ActivityType`
	/// - Parameter activityType: The app-specific `ActivityType`
	open func userActivity(for activityType: ActivityType) -> NSUserActivity {
		return NSUserActivity(activityType: identifiers[activityType.rawValue])
	}

	/// Initializes the CoreUserActivityManager with the `Bundle` containing the app's info dictionary
	/// - Parameter bundle: The `Bundle` containing the app's info dictionary
	public init(with bundle: Bundle = .main) {
		let activityTypesKey = "NSUserActivityTypes"
		guard let activityTypes = bundle.infoDictionary?[activityTypesKey] as? [String] else {
			fatalError("No info dictionary array for \(activityTypesKey)")
		}
		identifiers = activityTypes
	}
}
