//
//  CoreColumnLayoutAware.swift
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

/// Describes an entity that interacts with a single `CoreColumnLayoutProviding` instance
public protocol CoreColumnLayoutAware {
	
	/// The `CoreColumnLayoutProviding` instance
	var columnLayoutProvider: CoreColumnLayoutProviding? { get set }
}

/// Convenience methods for `CoreColumnLayoutAware` entities
public extension CoreColumnLayoutAware {
	
	/// Constrains a view to a column provided by the `columnLayoutProvider`
	///
	/// - Parameters:
	///   - layoutProvider: The Layout Provider to attach
	///   - column: The column which will attach to the view
	func constrainLayoutProvider(_ layoutProvider: CoreHorizontalLayoutAnchorable, to column: Int, with priority: LayoutPriority = .required) throws {
		guard let columnLayoutProvider = columnLayoutProvider else { throw CoreColumnLayoutError.columnLayoutProvidingNotAvailable }
		guard (0..<columnLayoutProvider.numberOfColumns).contains(column) else { throw CoreColumnLayoutError.invalidColumnSpecified(column, maxAllowed: columnLayoutProvider.numberOfColumns) }
		let columnProvider = columnLayoutProvider.layoutProvider(for: column)
		let constraints = columnProvider.constrainHorizontally(to: layoutProvider, with: priority)
		NSLayoutConstraint.activate(constraints)
	}
}

#endif
