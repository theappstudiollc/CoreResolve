//
//  CoreColumnLayoutClient.swift
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

import Foundation
#if os(iOS) || os(tvOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

/// Supports `ColumnLayoutAware` entities with more advanced capabilities than constrainLayoutProvider(_:to:with:)
public class CoreColumnLayoutClient {
	
	private var columnLayoutProvider: CoreColumnLayoutProviding
	
	private var columnConstraints: [HorizontalBoundingConstraints?]
	
	deinit {
		let allConstraints = columnConstraints.compactMap({ $0 }).flatMap { horizontalConstraints in
			return [horizontalConstraints.leading, horizontalConstraints.trailing]
		}
		NSLayoutConstraint.deactivate(allConstraints)
	}
	
	public init(columnLayoutProvider: CoreColumnLayoutProviding) {
		self.columnLayoutProvider = columnLayoutProvider
		columnConstraints = [HorizontalBoundingConstraints?](repeating: nil, count: columnLayoutProvider.numberOfColumns)
	}
	
	public func setEnabled(_ enabled: Bool, for column: Int) {
		guard let pair = columnConstraints[column] else { return }
		if enabled {
			NSLayoutConstraint.activate(pair)
		} else {
			NSLayoutConstraint.deactivate(pair)
		}
	}
	
	public func layout(layoutProvider: CoreHorizontalLayoutAnchorable, to column: Int, with priority: LayoutPriority = .required) throws {
		guard (0..<columnLayoutProvider.numberOfColumns).contains(column) else { throw CoreColumnLayoutError.invalidColumnSpecified(column, maxAllowed: columnLayoutProvider.numberOfColumns) }
		if let horizontalConstraints = columnConstraints[column] {
			NSLayoutConstraint.deactivate(horizontalConstraints)
		}
		let columnProvider = columnLayoutProvider.layoutProvider(for: column)
		let pair = columnProvider.constrainHorizontally(to: layoutProvider, with: priority)
		NSLayoutConstraint.activate(pair)
		columnConstraints[column] = pair
	}
}

#endif
