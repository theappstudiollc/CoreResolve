//
//  CoreColumnLayoutExtensions.swift
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

#if !os(watchOS)

#if os(iOS) || os(tvOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

// MARK: - Convenience methods for Layout Guides
public extension LayoutGuide {
	
	/// Initializes a new instance of LayoutGuide with a specified identifier
	///
	/// - Parameter identifier: The identifier for the Layout Guide
	convenience init(identifier: String) {
		self.init()
		#if os(macOS)
		self.identifier = NSUserInterfaceItemIdentifier(rawValue: identifier)
		#else
		self.identifier = identifier
		#endif
	}
}

extension NSLayoutConstraint: CoreResettable {

	public func reset() {
		isActive = false
	}
}

// MARK: - Convenience methods for NSLayoutConstraint that support CoreLayoutAnchorable
extension NSLayoutConstraint {

	/// Activates the `NSLayoutConstraints` defined within the provided boundingConstraints
	/// - Parameter boundingConstraints: A `BoundingConstraints` structure to activate
	public class func activate(_ boundingConstraints: BoundingConstraints) {
		activate(boundingConstraints.constraints)
	}

	/// Activates the `NSLayoutConstraints` defined within the provided boundingConstraints
	/// - Parameter horizontalBoundingConstraints: A `HorizontalBoundingConstraints` structure to activate
	public class func activate(_ horizontalBoundingConstraints: HorizontalBoundingConstraints) {
		activate(horizontalBoundingConstraints.constraints)
	}

	/// Activates the `NSLayoutConstraints` defined within the provided boundingConstraints
	/// - Parameter verticalBoundingConstraints: A `VerticalBoundingConstraints` structure to activate
	public class func activate(_ verticalBoundingConstraints: VerticalBoundingConstraints) {
		activate(verticalBoundingConstraints.constraints)
	}

	/// Deactivates the `NSLayoutConstraints` defined within the provided boundingConstraints
	/// - Parameter boundingConstraints: A `BoundingConstraints` structure to deactivate
	public class func deactivate(_ boundingConstraints: BoundingConstraints) {
		deactivate(boundingConstraints.constraints)
	}

	/// Deactivates the `NSLayoutConstraints` defined within the provided boundingConstraints
	/// - Parameter horizontalBoundingConstraints: A `HorizontalBoundingConstraints` structure to deactivate
	public class func deactivate(_ horizontalBoundingConstraints: HorizontalBoundingConstraints) {
		deactivate(horizontalBoundingConstraints.constraints)
	}

	/// Deactivates the `NSLayoutConstraints` defined within the provided boundingConstraints
	/// - Parameter verticalBoundingConstraints: A `VerticalBoundingConstraints` structure to deactivate
	public class func deactivate(_ verticalBoundingConstraints: VerticalBoundingConstraints) {
		deactivate(verticalBoundingConstraints.constraints)
	}
}

#endif
