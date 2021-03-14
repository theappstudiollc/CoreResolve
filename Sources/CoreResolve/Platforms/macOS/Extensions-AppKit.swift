//
//  Extensions-AppKit.swift
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

#if os(macOS)

import AppKit

extension IndexPath {
	
	/// Initialize for use with `NSTableView`.
	public init(column: Int, row: Int, section: Int) {
		self.init(indexes: [section, row, column])
	}
	
	/// The column of this index path, when used with `NSTableView`.
	///
	/// - precondition: The index path must have exactly three elements.
	public var column: Int { return self[2] }
	
	/// The row of this index path, when used with `NSTableView`.
	///
	/// - precondition: The index path must have exactly three elements.
	public var row: Int { return self[1] }
	
	/// The section of this index path, when used with `NSTableView`.
	///
	/// - precondition: The index path must have exactly three elements.
	public var section: Int { return self[0] }
}


extension NSEdgeInsets {
	
	public static let zero = NSEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
}

extension NSRect {
	
	public func inset(by insets: NSEdgeInsets) -> NSRect {
		var retVal = offsetBy(dx: insets.left, dy: insets.top)
		retVal.size.height -= insets.top + insets.bottom
		retVal.size.width -= insets.left + insets.right
		return retVal
	}
}

public extension NSResponder {

	func findResponder<T>(as: T.Type) -> T? {
		var result: NSResponder? = self
		while let checkResult = result, !(checkResult is T) {
			result = checkResult.nextResponder
		}
		return result as? T
	}
}

public extension NSStoryboardSegue {
	
	/// Match UIKit's `destination` property to enable shared code
	var destination: NSViewController {
		return destinationController as! NSViewController
	}
}

public extension NSView {
	
	/// Match UIKit's `alpha` property to enable shared code
	var alpha: CGFloat {
		get { return alphaValue }
		set { alphaValue = newValue }
	}
	
	/// Match UIKit's `backgroundColor` property to enable shared code
	var backgroundColor: NSColor? {
		get {
			guard let cgColor = layer?.backgroundColor else { return nil }
			return NSColor(cgColor: cgColor)
		}
		set { layer?.backgroundColor = newValue?.cgColor }
	}
}

public extension NSView.AutoresizingMask {
	
	/// The view will scale proportionally with the parent
	static let scalesWithParent: Self = [.height, .width]
}

#endif
