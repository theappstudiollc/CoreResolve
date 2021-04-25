//
//  CoreLayoutProviding.swift
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

/// Represents a collection of horizontally-oriented anchors with which to apply AutoLayout constraints
public protocol CoreHorizontalLayoutAnchorable: AnyObject {

	var leadingAnchor: NSLayoutXAxisAnchor { get }

	var trailingAnchor: NSLayoutXAxisAnchor { get }

	var leftAnchor: NSLayoutXAxisAnchor { get }

	var rightAnchor: NSLayoutXAxisAnchor { get }

	var widthAnchor: NSLayoutDimension { get }

	var centerXAnchor: NSLayoutXAxisAnchor { get }
}

// MARK: - Convenience methods for `CoreHorizontalLayoutAnchorable` instances
extension CoreHorizontalLayoutAnchorable {

	/// Horizontally constrains the calling `CoreHorizontalLayoutAnchorable` to the provided layoutAnchors
	/// - Parameters:
	///   - layoutAnchors: The `CoreHorizontalLayoutAnchorable` on which you wish to anchor the leading and trailing constraints
	///   - priority: The `LayoutPriority` of the leading and trailing constraints
	/// - Returns: A structure containing the leading and trailing constraints, which have not yet been activated
	public func constrainHorizontally(to layoutAnchors: CoreHorizontalLayoutAnchorable, with priority: LayoutPriority = .required) -> HorizontalBoundingConstraints {
		return constrainHorizontally(to: layoutAnchors, leadingPriority: priority, trailingPriority: priority)
	}

	/// Horizontally constrains the calling `CoreHorizontalLayoutAnchorable` to the provided layoutAnchors
	/// - Parameters:
	///   - layoutAnchors: The `CoreHorizontalLayoutAnchorable` on which you wish to anchor the leading and trailing constraints
	///   - leadingPriority: The `LayoutPriority` of the leading constraint
	///   - trailingPriority: The `LayoutPriority` of the trailing constraint
	/// - Returns: A structure containing the leading and trailing constraints, which have not yet been activated
	public func constrainHorizontally(to layoutAnchors: CoreHorizontalLayoutAnchorable, leadingPriority: LayoutPriority = .required, trailingPriority: LayoutPriority = .required) -> HorizontalBoundingConstraints {
		let leading = leadingAnchor.constraint(equalTo: layoutAnchors.leadingAnchor)
		let trailing = layoutAnchors.trailingAnchor.constraint(equalTo: trailingAnchor)
		leading.priority = leadingPriority
		trailing.priority = trailingPriority
		return HorizontalBoundingConstraints(leading: leading, trailing: trailing)
	}

	/// The current width of the `CoreHorizontalLayoutAnchorable` instance as known to AutoLayout
	public var currentLayoutWidth: CGFloat {
		switch self {
		case let layoutGuide as LayoutGuide:
			#if os(macOS)
				return layoutGuide.frame.width
			#else
				return layoutGuide.layoutFrame.width
			#endif
		case let view as View:
			return view.bounds.width
		default:
			return 0
		}
	}
}

/// Represents a collection of vertically-oriented anchors with which to apply AutoLayout constraints
public protocol CoreVerticalLayoutAnchorable {

	var topAnchor: NSLayoutYAxisAnchor { get }

	var bottomAnchor: NSLayoutYAxisAnchor { get }

	var heightAnchor: NSLayoutDimension { get }

	var centerYAnchor: NSLayoutYAxisAnchor { get }
}

// MARK: - Convenience methods for `CoreVerticalLayoutAnchorable` instances
extension CoreVerticalLayoutAnchorable {

	/// Vertically constrains the calling `CoreVerticalLayoutAnchorable` to the provided layoutAnchors
	/// - Parameters:
	///   - layoutAnchors: The `CoreVerticalLayoutAnchorable` on which you wish to anchor the top and bottom constraints
	///   - priority: The `LayoutPriority` of the top and bottom constraints
	/// - Returns: A structure containing the top and bottom constraints, which have not yet been activated
	public func constrainVertically(to layoutAnchors: CoreVerticalLayoutAnchorable, with priority: LayoutPriority = .required) -> VerticalBoundingConstraints {
		let top = topAnchor.constraint(equalTo: layoutAnchors.topAnchor)
		let bottom = layoutAnchors.bottomAnchor.constraint(equalTo: bottomAnchor)
		top.priority = priority
		bottom.priority = priority
		return VerticalBoundingConstraints(top: top, bottom: bottom)
	}
}

/// Represents a class that can provide anchors with which to apply AutoLayout constraints
public protocol CoreLayoutAnchorable: CoreHorizontalLayoutAnchorable, CoreVerticalLayoutAnchorable {

	@available(iOS 11, macOS 11, tvOS 11, *)
	/// The insets that you use to determine the safe area for this `CoreLayoutAnchorable`.
	var safeAreaInsets: EdgeInsets { get }
}

extension CoreLayoutAnchorable {

	/// Constrains the calling `CoreLayoutAnchorable` to the provided layoutAnchors
	/// - Parameters:
	///   - layoutAnchors: The `CoreLayoutAnchorable` on which you wish to anchor leading, trailing, top, and bottom constraints
	///   - priority: The `LayoutPriority` of all constraints
	/// - Returns: A structure containing horizontal and vertical constraint structures, which have not yet been activated
	public func constrain(to layoutAnchors: CoreLayoutAnchorable, with priority: LayoutPriority = .required) -> BoundingConstraints {
		let horizontals = constrainHorizontally(to: layoutAnchors, with: priority)
		let verticals = constrainVertically(to: layoutAnchors, with: priority)
		return BoundingConstraints(horizontal: horizontals, vertical: verticals)
	}

	/// The current frame of the `CoreLayoutAnchorable` instance as known to AutoLayout
	public var layoutFrame: CGRect {
		switch self {
		case let layoutGuide as LayoutGuide:
			#if os(macOS)
				return layoutGuide.frame
			#else
				return layoutGuide.layoutFrame
			#endif
		case let view as View:
			return view.bounds
		default:
			return .zero
		}
	}
}

// MARK: - Marks LayoutGuide as `CoreLayoutAnchorable`
extension LayoutGuide: CoreLayoutAnchorable {

	@available(iOS 11, macOS 11, tvOS 11, *)
	public var safeAreaInsets: EdgeInsets {
		guard let owningView = owningView else { return .zero }
		return owningView.safeAreaInsets
	}
}

// MARK: - Marks View as `CoreLayoutAnchorable`
extension View: CoreLayoutAnchorable { }

#endif
