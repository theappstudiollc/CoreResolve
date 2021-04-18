//
//  BoundingConstraints.swift
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

#if !os(watchOS)

#if os(iOS) || os(tvOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

public struct BoundingConstraints {

	/// The horizontal bounding constraints
	public let horizontal: HorizontalBoundingConstraints

	/// The vertical bounding constraints
	public let vertical: VerticalBoundingConstraints

	/// Creates a new instance of `BoundingConstraints`
	/// - Parameters:
	///   - horizontal: The HorizontalBoundingConstraints
	///   - vertical: The VerticalBoundingConstraints
	public init(horizontal: HorizontalBoundingConstraints, vertical: VerticalBoundingConstraints) {
		self.horizontal = horizontal
		self.vertical = vertical
	}
}

extension BoundingConstraints {

	/// Provides an Array of the NSLayoutConstraints in the struct with unspecified order. Primarily useful for activating and deactivating as a collection
	public var constraints: [NSLayoutConstraint] {
		return horizontal.constraints + vertical.constraints
	}
}

public struct HorizontalBoundingConstraints {

	/// The leading layout constraint, where a positive constant increases the padding
	public let leading: NSLayoutConstraint

	/// The trailing layout constraint, where a positive constant increases the padding
	public let trailing: NSLayoutConstraint

	/// Creates a new instance of `HorizontalBoundingConstraints`
	/// - Parameters:
	///   - leading: The leading NSLayoutConstraint
	///   - trailing: The trailing NSLayoutConstraint
	public init(leading: NSLayoutConstraint, trailing: NSLayoutConstraint) {
		self.leading = leading
		self.trailing = trailing
	}
}

extension HorizontalBoundingConstraints {

	/// Provides an Array of the NSLayoutConstraints in the struct with unspecified order. Primarily useful for activating and deactivating as a collection
	public var constraints: [NSLayoutConstraint] {
		return [leading, trailing]
	}
}

public struct VerticalBoundingConstraints {

	/// The top layout constraint, where a positive constant increases the padding
	public let top: NSLayoutConstraint

	/// The bottom layout constraint, where a positive constant increases the padding
	public let bottom: NSLayoutConstraint

	/// Creates a new instance of `VerticalBoundingConstraints`
	/// - Parameters:
	///   - top: The top NSLayoutConstraint
	///   - bottom: The bottom NSLayoutConstraint
	public init(top: NSLayoutConstraint, bottom: NSLayoutConstraint) {
		self.top = top
		self.bottom = bottom
	}
}

extension VerticalBoundingConstraints {

	/// Provides an Array of the NSLayoutConstraints in the struct with unspecified order. Primarily useful for activating and deactivating as a collection
	public var constraints: [NSLayoutConstraint] {
		return [top, bottom]
	}
}

#endif
