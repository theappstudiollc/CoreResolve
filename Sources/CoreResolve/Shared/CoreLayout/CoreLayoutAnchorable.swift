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
public protocol CoreHorizontalLayoutAnchorable: class {
	
	var leadingAnchor: NSLayoutXAxisAnchor { get }
	
	var trailingAnchor: NSLayoutXAxisAnchor { get }
	
	var leftAnchor: NSLayoutXAxisAnchor { get }
	
	var rightAnchor: NSLayoutXAxisAnchor { get }
	
	var widthAnchor: NSLayoutDimension { get }
	
	var centerXAnchor: NSLayoutXAxisAnchor { get }
}

// MARK: - Convenience methods for `CoreHorizontalLayoutAnchorable` instances
extension CoreHorizontalLayoutAnchorable {
	
	@discardableResult public func constrainHorizontally(to layoutAnchors: CoreHorizontalLayoutAnchorable, with priority: LayoutPriority = .required) -> [NSLayoutConstraint] {
		let leading = leadingAnchor.constraint(equalTo: layoutAnchors.leadingAnchor)
		let trailing = trailingAnchor.constraint(equalTo: layoutAnchors.trailingAnchor)
		leading.priority = priority
		trailing.priority = priority
		leading.isActive = true
		trailing.isActive = true
		return [leading, trailing]
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
	
	@discardableResult public func constrainVertically(to layoutAnchors: CoreVerticalLayoutAnchorable, with priority: LayoutPriority = .required) -> [NSLayoutConstraint] {
		let top = topAnchor.constraint(equalTo: layoutAnchors.topAnchor)
		let bottom = bottomAnchor.constraint(equalTo: layoutAnchors.bottomAnchor)
		top.priority = priority
		bottom.priority = priority
		top.isActive = true
		bottom.isActive = true
		return [top, bottom]
	}
}

/// Represents a class that can provide anchors with which to apply AutoLayout constraints
public protocol CoreLayoutAnchorable: CoreHorizontalLayoutAnchorable, CoreVerticalLayoutAnchorable { }

extension CoreLayoutAnchorable {
	
	@discardableResult public func constrain(to layoutAnchors: CoreLayoutAnchorable, with priority: LayoutPriority = .required) -> [NSLayoutConstraint] {
		let horizontals = constrainHorizontally(to: layoutAnchors, with: priority)
		let verticals = constrainVertically(to: layoutAnchors, with: priority)
		return horizontals + verticals
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
extension LayoutGuide: CoreLayoutAnchorable { }

// MARK: - Marks View as `CoreLayoutAnchorable`
extension View: CoreLayoutAnchorable { }

#endif
