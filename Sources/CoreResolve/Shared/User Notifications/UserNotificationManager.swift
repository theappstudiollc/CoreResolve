//
//  UserNotificationManager.swift
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

import UserNotifications

@available(iOS 10.0, macOS 10.14, watchOS 3.0, *)
public final class UserNotificationManager: CoreRemoteNotificationAdapter, CoreNotificationProviding {

	fileprivate let notificationProvider: UNUserNotificationCenter
	
	public init(application: Application, notificationDelegate: CoreRemoteNotificationAdaptingDelegate? = nil, notificationProvider: UNUserNotificationCenter = .current()) {
		self.notificationProvider = notificationProvider
		super.init(application: application, notificationDelegate: notificationDelegate)
		#if !os(tvOS)
		notificationProvider.delegate = self
		#endif
	}

	@available(macOS 10.14, watchOS 6.0, *)
	public override func registerForRemoteNotifications() {
		#if os(macOS)
		guard !application.isRegisteredForRemoteNotifications else { return }
		#endif
		super.registerForRemoteNotifications()
	}

	public func requestAuthorization(options: CoreNotification.AuthorizationOptions, completionHandler: @escaping (Result<Void, Error>) -> Void) {
		dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
		notificationProvider.requestAuthorization(options: UNAuthorizationOptions(from: options)) { success, error in
			if let error = error {
				completionHandler(.failure(error))
			} else {
				completionHandler(.success(()))
			}
		}
	}

	@available(tvOS, unavailable)
	public func setNotificationCategories(_ categories: Set<CoreNotification.Category>) {
		let categories = Set(categories.map { UNNotificationCategory(from: $0) })
		notificationProvider.setNotificationCategories(categories)
	}
}

#if !os(tvOS)

@available(iOS 10.0, macOS 10.14, watchOS 3.0, *)
extension UserNotificationManager: UNUserNotificationCenterDelegate {
	
	// TODO: Pass these three off to the CoreNotificationProvidingDelegate
	#if !os(watchOS)

	public func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
		
	}

	#endif

	public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
		completionHandler()
	}
	
	public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
		completionHandler([.alert, .badge, .sound])
	}
}

#endif

@available(iOS 10.0, macCatalyst 13.0, macOS 10.14, watchOS 3.0, *)
extension UNAuthorizationOptions {
	
	init(from authorizationOptions: CoreNotification.AuthorizationOptions) {
		var result = UNAuthorizationOptions()
		if authorizationOptions.contains(.badge) {
			result.formUnion(.badge)
		}
		#if !os(tvOS)
		if authorizationOptions.contains(.alert) {
			result.formUnion(.alert)
		}
		if authorizationOptions.contains(.carPlay) {
			result.formUnion(.carPlay)
		}
		if authorizationOptions.contains(.sound) {
			result.formUnion(.sound)
		}
		#if targetEnvironment(macCatalyst) // This is equivalent to iOS 13+
		if authorizationOptions.contains(.criticalAlert) {
			result.formUnion(.criticalAlert)
		}
		if authorizationOptions.contains(.providesAppNotificationSettings) {
			result.formUnion(.providesAppNotificationSettings)
		}
		if authorizationOptions.contains(.provisional) {
			result.formUnion(.provisional)
		}
		#else
		if #available(iOS 12.0, watchOS 5.0, *), authorizationOptions.contains(.criticalAlert) {
			result.formUnion(.criticalAlert)
		}
		if #available(iOS 12.0, watchOS 5.0, *), authorizationOptions.contains(.providesAppNotificationSettings) {
			result.formUnion(.providesAppNotificationSettings)
		}
		if #available(iOS 12.0, watchOS 5.0, *), authorizationOptions.contains(.provisional) {
			result.formUnion(.provisional)
		}
		#endif
		#endif
		self.init(rawValue: result.rawValue)
	}
}

@available(iOS 10.0, macOS 10.14, watchOS 3.0, *) @available(tvOS, unavailable)
extension UNNotificationAction {
	
	public convenience init(from action: CoreNotification.Action) {
		let options = UNNotificationActionOptions(from: action.options)
		self.init(identifier: action.identifier, title: action.title, options: options)
	}
}

@available(iOS 10.0, macOS 10.14, watchOS 3.0, *) @available(tvOS, unavailable)
extension UNNotificationActionOptions {
	
	public init(from options: CoreNotification.ActionOptions) {
		var result = UNNotificationActionOptions()
		if options.contains(.authenticationRequired) {
			result.formUnion(.authenticationRequired)
		}
		if options.contains(.destructive) {
			result.formUnion(.destructive)
		}
		if options.contains(.foreground) {
			result.formUnion(.foreground)
		}
		self.init(rawValue: result.rawValue)
	}
}

@available(iOS 10.0, macOS 10.14, watchOS 3.0, *) @available(tvOS, unavailable)
extension UNNotificationCategory {
	
	public convenience init(from category: CoreNotification.Category) {
		let actions = category.actions.map { UNNotificationAction(from: $0) }
		let options = UNNotificationCategoryOptions(from: category.options)
		#if targetEnvironment(macCatalyst) // This is equivalent to iOS 13+
			self.init(identifier: category.identifier, actions: actions, intentIdentifiers: category.intentIdentifiers, hiddenPreviewsBodyPlaceholder: category.hiddenPreviewsBodyPlaceholder, categorySummaryFormat: category.categorySummaryFormat, options: options)
		#elseif os(watchOS)
			self.init(identifier: category.identifier, actions: actions, intentIdentifiers: category.intentIdentifiers, options: options)
		#else
			if #available(iOS 12.0, *) {
				self.init(identifier: category.identifier, actions: actions, intentIdentifiers: category.intentIdentifiers, hiddenPreviewsBodyPlaceholder: category.hiddenPreviewsBodyPlaceholder, categorySummaryFormat: category.categorySummaryFormat, options: options)
			} else if #available(iOS 11.0, *), let hiddenPreviewsBodyPlaceholder = category.hiddenPreviewsBodyPlaceholder {
				self.init(identifier: category.identifier, actions: actions, intentIdentifiers: category.intentIdentifiers, hiddenPreviewsBodyPlaceholder: hiddenPreviewsBodyPlaceholder, options: options)
			} else {
				self.init(identifier: category.identifier, actions: actions, intentIdentifiers: category.intentIdentifiers, options: options)
			}
		#endif
	}
}

@available(iOS 10.0, macOS 10.14, watchOS 3.0, *) @available(tvOS, unavailable)
extension UNNotificationCategoryOptions {
	
	public init(from options: CoreNotification.CategoryOptions) {
		var result = UNNotificationCategoryOptions()
		#if os(iOS) // not available on macOS
		if options.contains(.allowInCarPlay) {
			result.formUnion(.allowInCarPlay)
		}
		#endif
		if options.contains(.customDismissAction) {
			result.formUnion(.customDismissAction)
		}
		#if targetEnvironment(macCatalyst) // This is equivalent to iOS 13+
		if options.contains(.hiddenPreviewsShowSubtitle) {
			result.formUnion(.hiddenPreviewsShowSubtitle)
		}
		if options.contains(.hiddenPreviewsShowTitle) {
			result.formUnion(.hiddenPreviewsShowTitle)
		}
		#elseif !os(watchOS)
		if #available(iOS 11.0, *), options.contains(.hiddenPreviewsShowSubtitle) {
			result.formUnion(.hiddenPreviewsShowSubtitle)
		}
		if #available(iOS 11.0, *), options.contains(.hiddenPreviewsShowTitle) {
			result.formUnion(.hiddenPreviewsShowTitle)
		}
		#endif
		self.init(rawValue: result.rawValue)
	}
}
