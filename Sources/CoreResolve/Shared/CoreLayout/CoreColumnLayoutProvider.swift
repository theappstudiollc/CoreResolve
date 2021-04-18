//
//  CoreColumnLayoutProvider.swift
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

/// LayoutGuide subclass that provides `CoreColumnLayoutProviding` capabilities
public class CoreColumnLayoutProvider: LayoutGuide {
	
	public enum Spacing {
		@available(iOS 11.0, tvOS 11.0, *)
		case system
		case custom(_ spacing: CGFloat)
	}
	
	public private(set) var spacing: Spacing
	
	required public init(numberOfColumns: Int, spacing: Spacing = .custom(0)) {
		
		precondition(numberOfColumns > 1, "\(CoreColumnLayoutProvider.self)(numberOfColumns:) must be at least 2")
		
		self.spacing = spacing
		let layoutGuides: [CoreLayoutAnchorable] = (0..<numberOfColumns).map {
			LayoutGuide(identifier: "\(CoreColumnLayoutProvider.self).column.\($0)")
		}
		self.spacers = (0..<numberOfColumns - 1).map { column in
			let current = layoutGuides[column]
			let next = layoutGuides[column + 1]
			let identifier = "\(CoreColumnLayoutProvider.self).spacer.\(column)"
			switch spacing {
			case .system:
                #if os(iOS) || os(tvOS)
				if #available(iOS 11.0, tvOS 11.0, *) {
					let systemSpacer: NSLayoutConstraint
					// Work around an iOS 14.x bug by building the system spacing constraint off of a UIView vs a UILayoutGuide
					#if false
					systemSpacer = next.leadingAnchor.constraint(equalToSystemSpacingAfter: current.trailingAnchor, multiplier: 1)
					#else
					switch (next, current) {
					case (let view as UIView, let current):
						systemSpacer = view.leadingAnchor.constraint(equalToSystemSpacingAfter: current.trailingAnchor, multiplier: 1)
					case (let next, let view as UIView):
						systemSpacer = view.trailingAnchor.constraint(equalToSystemSpacingAfter: next.leadingAnchor, multiplier: 1)
					default: // Fall back to a regular spacing constraint
						systemSpacer = next.leadingAnchor.constraint(equalTo: current.trailingAnchor, constant: 8)
					}
					#endif
					systemSpacer.identifier = identifier
					return systemSpacer
				}
                #endif
				let spacer = next.leadingAnchor.constraint(equalTo: current.trailingAnchor, constant: 8)
				spacer.identifier = identifier
				return spacer
			case .custom(let spacing):
				let spacer = next.leadingAnchor.constraint(equalTo: current.trailingAnchor, constant: spacing)
				spacer.identifier = identifier
				return spacer
			}
		}
		self.columns = layoutGuides
		super.init()
	}
	
	required init?(coder aDecoder: NSCoder) {
		// This is not implemented because we don't allow changing numberOfColumns or spacing after the fact (for now)
		fatalError("init(coder:) has not been implemented")
	}
	
    public override var owningView: View? {
        didSet { updateOwningView() }
    }
	
	fileprivate let columns: [CoreLayoutAnchorable]
	
	fileprivate var constraintPair: [NSLayoutConstraint]?
	
	fileprivate let spacers: [NSLayoutConstraint]
	
	private func updateOwningView() {
		// TODO: Consider the scenario when the owning view is nil
		guard let view = owningView else { return }
		columns.map({ $0 as! LayoutGuide }).forEach { layoutGuide in
			view.addLayoutGuide(layoutGuide)
			NSLayoutConstraint.activate(layoutGuide.constrainVertically(to: self))
		}
		NSLayoutConstraint.activate(spacers)
		let leading = leadingAnchor.constraint(equalTo: columns[0].leadingAnchor)
		let trailing = trailingAnchor.constraint(equalTo: columns[numberOfColumns - 1].trailingAnchor)
		constraintPair = [leading, trailing]
		NSLayoutConstraint.activate([leading, trailing])
	}
}

// MARK: - `CoreColumnLayoutProviding` support
extension CoreColumnLayoutProvider: CoreColumnLayoutProviding {
	
	public var numberOfColumns: Int {
		return columns.count
	}
	
	public func layoutProvider(for column: Int) -> CoreHorizontalLayoutAnchorable {
		return columns[column]
	}
}

#endif
