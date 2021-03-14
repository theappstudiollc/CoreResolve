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
	
	private typealias DisposableConstraints = [NSLayoutConstraint]
	
	private var columnLayoutProvider: CoreColumnLayoutProviding
	
	private var columnConstraints: [DisposableConstraints?]
	
	deinit {
		columnConstraints.forEach { $0?.reset() }
	}
	
	public init(columnLayoutProvider: CoreColumnLayoutProviding) {
		self.columnLayoutProvider = columnLayoutProvider
		columnConstraints = [DisposableConstraints?](repeating: nil, count: columnLayoutProvider.numberOfColumns)
	}
	
	public func setEnabled(_ enabled: Bool, for column: Int) {
		if let pair = columnConstraints[column] {
			pair.first!.isActive = enabled
			pair.last!.isActive = enabled
		}
	}
	
	public func layout(layoutProvider: CoreHorizontalLayoutAnchorable, to column: Int, with priority: LayoutPriority = .required) {
		columnConstraints[column]?.reset()
		let columnProvider = columnLayoutProvider.layoutProvider(for: column)
		let pair = columnProvider.constrainHorizontally(to: layoutProvider, with: priority)
		columnConstraints[column] = pair
	}
}

#endif
