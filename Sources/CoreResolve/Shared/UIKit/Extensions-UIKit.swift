//
//  Extensions-UIKit.swift
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

#if canImport(UIKit) && !os(watchOS)

import CoreResolve_ObjC
import UIKit

public extension UIApplication {
	
    /// A task handler that performs a background task
	typealias TaskHandler = (_ estimatedTimeRemaining: TimeInterval, _ notifyCompletion: @escaping () -> Void) -> Void
    
    /// A task completion closure when a background task is completed or cancelled
	typealias TaskCompletion = (_ taskExpired: Bool) -> Void
	
    /// Closure-based mechanism to run and manage a UIApplication BackgroundTask
    ///
    /// - Parameters:
    ///   - taskName: The name of the background task
    ///   - task: A TaskHandler which should perform the background task
    ///   - completion: A TaskCompletion that will be called when the background task is completed or cancelled
	func continueTaskIfBackgrounded(withName taskName: String, task: TaskHandler, completion: TaskCompletion? = nil) {
		var taskIdentifier = UIBackgroundTaskIdentifier.invalid
		taskIdentifier = beginBackgroundTask(withName: taskName) {
			guard taskIdentifier != .invalid else { return }
			let endingIdentifier = taskIdentifier
			taskIdentifier = .invalid
			completion?(true)
			self.endBackgroundTask(endingIdentifier)
		}
		task(backgroundTimeRemaining) {
			guard taskIdentifier != .invalid else { return }
			let endingIdentifier = taskIdentifier
			taskIdentifier = .invalid
			completion?(false)
			self.endBackgroundTask(endingIdentifier)
		}
	}
}

/// Support better initial sizing by working around a few known issues before the View is returned to the DataSource
public protocol CoreTableViewPreparesViewsForSizing {
	
	var cellRequiresPreparation: Bool { get }
	
	func prepareViewForSizing(_ view: UIView)
	
	var sectionFooterRequiresPreparation: Bool { get }

	var sectionHeaderRequiresPreparation: Bool { get }
}

public extension CoreTableViewPreparesViewsForSizing where Self: UITableView {
	
	var cellRequiresPreparation: Bool {
		return rowHeight == UITableView.automaticDimension
	}
	
	var sectionFooterRequiresPreparation: Bool {
		return sectionFooterHeight == UITableView.automaticDimension
	}

	var sectionHeaderRequiresPreparation: Bool {
		return sectionHeaderHeight == UITableView.automaticDimension
	}
	
	func prepareViewForSizing(_ view: UIView) {
		
		// Ensure the views match the current UITableView (instead of their configured size in Interface Builder)
		// They cannot properly know their height until their width is properly set
		if view.frame.width != bounds.width {
			view.frame.size.width = bounds.width
		}
		
		// Appearance API properties (especially fonts) don't get applied until the view is part of the window hierarchy
		// Doing this now ensures that when the view is asked to size itself, it has everything it needs to do it right the first time
		if view.superview == nil {
			addSubview(view)
		}
	}
}

public extension UIFont {

	/// Returns a font based on the receiver, with the specified `UIFont.TextStyle` (currently experimental, and therefore internal)
	/// - Parameter textStyle: The desired `UIFont.TextStyle` of the returned font
	/// - Throws: This may throw an Error in cases where an already scaled font is used as the receiver
	/// - Returns: Returns a scaled font with the desired `UIFont.TextStyle`
	internal func scaledFor(textStyle: UIFont.TextStyle) throws -> UIFont {

		guard let fontAttribute = fontDescriptor.fontAttributes.first(where: { $0.key == .nsctFontUIUsage }) else {
			guard #available(iOS 11, tvOS 11, *) else {
				return UIFont(descriptor: fontDescriptor.addingAttributes([.nsctFontUIUsage : textStyle]), size: pointSize)
			}
			let fontMetrics = UIFontMetrics(forTextStyle: textStyle)
			var scaled: UIFont! = nil
			try CRKObjectiveC.catchExceptionAndThrow {
				scaled = fontMetrics.scaledFont(for: self) // This may throw an NSException
			}
			return scaled
		}
		guard let fontTextStyle = fontAttribute.value as? UIFont.TextStyle, fontTextStyle == textStyle else {
			return UIFont(descriptor: fontDescriptor.addingAttributes([.nsctFontUIUsage : textStyle]), size: pointSize)
		}
		return self
	}
}

public extension UIResponder {

	func findResponder<T>(as: T.Type) -> T? {
		var result: UIResponder? = self
		while let checkResult = result, !(checkResult is T) {
			result = checkResult.next
		}
		return result as? T
	}
}
/* This causes a lot of side-effects
extension UIResponder: Sequence {

	public struct Iterator : IteratorProtocol {
		public typealias Element = UIResponder

		var source: UIResponder?

		init(source: UIResponder) {
			self.source = source
		}

		mutating public func next() -> UIResponder? {
			source = source?.next
			return source
		}
	}

	public __consuming func makeIterator() -> UIResponder.Iterator {
		return Iterator(source: self)
	}
}
*/
public extension UIView {
	
    /// Captures a screenshot of the UIView
    ///
    /// - Returns: Returns a UIImage if the screenshot is successful
	func screenshot() -> UIImage? {
		defer { UIGraphicsEndImageContext() }
		UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
		if drawHierarchy(in: bounds, afterScreenUpdates: false) {
			return UIGraphicsGetImageFromCurrentImageContext()
		}
		return nil
	}
}

public extension UIView.AutoresizingMask {
	
	/// The view will scale proportionally with the parent
	static let scalesWithParent: Self = [.flexibleHeight, .flexibleWidth]
}

internal extension UIFontDescriptor.AttributeName {

	/// Attribute used for accessibility scaling
	static let nsctFontUIUsage = UIFontDescriptor.AttributeName(rawValue: "NSCTFontUIUsageAttribute")
}

#endif
