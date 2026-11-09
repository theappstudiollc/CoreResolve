//
//  NotificationConversionTests.swift
//  CoreResolve
//
//  Created by David Mitchell
//  Copyright © 2026 The App Studio LLC.
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

#if !os(tvOS)
import UserNotifications
import Testing
@testable import CoreResolve

struct NotificationConversionTests {
    @Test func authorizationOptionsPreserveRequestedFlags() {
        let source: CoreNotification.AuthorizationOptions = [.badge, .sound, .alert, .criticalAlert, .provisional, .providesAppNotificationSettings]
        let expected: UNAuthorizationOptions = [.badge, .sound, .alert, .criticalAlert, .provisional, .providesAppNotificationSettings]
        #expect(UNAuthorizationOptions(from: source) == expected)
        #expect(UNAuthorizationOptions(from: []) == [])
    }

    @Test func actionPreservesIdentifierTitleAndOptions() {
        let source = CoreNotification.Action(identifier: "open", title: "Open", options: [.authenticationRequired, .foreground, .destructive])
        let action = UNNotificationAction(from: source)
        #expect(action.identifier == "open")
        #expect(action.title == "Open")
        #expect(action.options == [.authenticationRequired, .foreground, .destructive])
    }

    @Test func categoryPreservesActionsAndMetadata() {
        let source = CoreNotification.Category(identifier: "message", actions: [
            .init(identifier: "open", title: "Open", options: .foreground),
            .init(identifier: "delete", title: "Delete", options: .destructive)
        ], intentIdentifiers: ["ReadMessage"], options: .customDismissAction,
           hiddenPreviewsBodyPlaceholder: "New message", categorySummaryFormat: "%u messages")
        let category = UNNotificationCategory(from: source)
        #expect(category.identifier == "message")
        #expect(category.actions.map(\.identifier) == ["open", "delete"])
        #expect(category.actions.map(\.title) == ["Open", "Delete"])
        #expect(category.intentIdentifiers == ["ReadMessage"])
        #expect(category.options == .customDismissAction)
        #if !os(watchOS)
        #expect(category.hiddenPreviewsBodyPlaceholder == "New message")
        #expect(category.categorySummaryFormat == "%u messages")
        #endif
    }

    @Test func emptyCategoryHasNoActionsOrOptions() {
        let category = UNNotificationCategory(from: .init(identifier: "empty", actions: [], intentIdentifiers: []))
        #expect(category.actions.isEmpty)
        #expect(category.intentIdentifiers.isEmpty)
        #expect(category.options.isEmpty)
    }

    #if !os(watchOS)
    @Test func previewOptionsAreConverted() {
        #expect(UNNotificationCategoryOptions(from: [.hiddenPreviewsShowTitle, .hiddenPreviewsShowSubtitle]) == [.hiddenPreviewsShowTitle, .hiddenPreviewsShowSubtitle])
    }
    #endif
}
#endif
