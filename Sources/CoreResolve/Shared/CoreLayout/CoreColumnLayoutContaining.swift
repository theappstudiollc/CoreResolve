//
//  CoreColumnLayoutContaining.swift
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

/// Describes a container of a single `CoreColumnLayoutProviding` instance
public protocol CoreColumnLayoutContaining {
	
	/// The `CoreColumnLayoutProviding` instance for this container
	var columnLayoutProvider: CoreColumnLayoutProviding { get }
}

// MARK: - Convenience methods for Views that are CoreColumnLayoutContaining
public extension CoreColumnLayoutContaining where Self: View {
	
	/// Configures the columnLayoutProvider to provide `CoreColumnLayoutProviding` capability to the current View
	///
	/// - Parameter layoutProvider: The desired Layout Provider of the View with which to map the leading and trailing anchors of the columnLayoutProvider
	/// - Returns: A Disposable array of constraints created to horizontally constrain the columnLayoutProvider to the layoutProvider parameter
	@discardableResult func configureColumns(to layoutProvider: CoreHorizontalLayoutAnchorable) -> [NSLayoutConstraint] {
		
		switch columnLayoutProvider {
		case let columnLayoutGuide as LayoutGuide:
			addLayoutGuide(columnLayoutGuide)
		case let view as View:
			addSubview(view)
		default:
			break
		}
		return columnLayoutProvider.constrainHorizontally(to: layoutProvider)
	}
}

#endif
