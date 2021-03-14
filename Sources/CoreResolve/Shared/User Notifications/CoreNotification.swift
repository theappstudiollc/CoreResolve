//
//  CoreNotification.swift
//  CoreResolve
//
//  Created by David Mitchell
//  Copyright © 2019 The App Studio LLC.
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

public enum CoreNotification {
	
	@available(tvOS, unavailable)
	public struct Action: Hashable {
		public var identifier: String
		public var title: String
		public var options: ActionOptions
		public var textInputButtonTitle: String?
		public var textInputPlaceholder: String?
	}
	
	@available(tvOS, unavailable)
	public struct ActionOptions: OptionSet, Hashable {
		public let rawValue: UInt
		public init(rawValue: UInt) {
			self.rawValue = rawValue
		}
		
		public static let authenticationRequired = ActionOptions(rawValue: 1 << 0)
		public static let destructive = ActionOptions(rawValue: 1 << 1)
		public static let foreground = ActionOptions(rawValue: 1 << 2)
	}
	
	public struct AuthorizationOptions: OptionSet {
		public let rawValue: UInt
		public init(rawValue: UInt) {
			self.rawValue = rawValue
		}

		/// Authorization for app badges -- for tvOS this is the only allowed option
		public static let badge = AuthorizationOptions(rawValue: 1 << 0)
		@available(tvOS, unavailable)
		public static let sound = AuthorizationOptions(rawValue: 1 << 1)
		@available(tvOS, unavailable)
		public static let alert = AuthorizationOptions(rawValue: 1 << 2)
		
		@available(iOS 10.0, *) @available(tvOS, unavailable)
		public static let carPlay = AuthorizationOptions(rawValue: 1 << 3)
		
		@available(iOS 12.0, watchOS 5.0, *) @available(tvOS, unavailable)
		public static let criticalAlert = AuthorizationOptions(rawValue: 1 << 4)
		
		@available(iOS 12.0, watchOS 5.0, *) @available(tvOS, unavailable)
		public static let providesAppNotificationSettings = AuthorizationOptions(rawValue: 1 << 5)
		
		@available(iOS 12.0, watchOS 5.0, *) @available(tvOS, unavailable)
		public static let provisional = AuthorizationOptions(rawValue: 1 << 6)
	}
	
	@available(tvOS, unavailable)
	public struct Category: Hashable {
		public var identifier: String
		public var actions: [Action]
		public var intentIdentifiers: [String]
		public var options: CategoryOptions
//		@available(iOS 11.0, *)
		public var hiddenPreviewsBodyPlaceholder: String?
//		@available(iOS 12.0, *)
		public var categorySummaryFormat: String?
		
		public init(identifier: String, actions: [Action], intentIdentifiers: [String], options: CategoryOptions = .none, hiddenPreviewsBodyPlaceholder: String? = nil, categorySummaryFormat: String? = nil) {
			self.identifier = identifier
			self.actions = actions
			self.intentIdentifiers = intentIdentifiers
			self.options = options
			self.hiddenPreviewsBodyPlaceholder = hiddenPreviewsBodyPlaceholder
			self.categorySummaryFormat = categorySummaryFormat
		}
	}

	@available(tvOS, unavailable)
	public struct CategoryOptions: OptionSet, Hashable {
		public let rawValue: UInt
		public init(rawValue: UInt) {
			self.rawValue = rawValue
		}
		
		public static let none = CategoryOptions([])
		public static let customDismissAction = CategoryOptions(rawValue: 1 << 0)
		#if os(iOS)
		public static let allowInCarPlay = CategoryOptions(rawValue: 1 << 1)
		#endif
		#if !os(watchOS)
		@available(iOS 11.0, *)
		public static let hiddenPreviewsShowTitle = CategoryOptions(rawValue: 1 << 2)
		@available(iOS 11.0, *)
		public static let hiddenPreviewsShowSubtitle = CategoryOptions(rawValue: 1 << 3)
		#endif
	}
}
