//
//  CoreTableViewDequeuing.swift
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

#if os(iOS) || os(tvOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

/// Represents a Table or CollectionView that can dequeue cells via an identifier
public protocol CoreCellDequeuing {
	
	/// A RawRepresentable type that represents a cell's identifier(s) (e.g. a String-based enum)
	associatedtype CellIdentifier: RawRepresentable where CellIdentifier.RawValue: StringProtocol
}

#if !os(watchOS)

public extension CoreCellDequeuing where Self: TableView, CellIdentifier.RawValue == String {

	#if canImport(UIKit)
	
	func dequeueReusableCell<T>(withIdentifier identifier: CellIdentifier, for indexPath: IndexPath) -> T where T: UITableViewCell {
		return self.dequeueReusableCell(withIdentifier: identifier.rawValue, for: indexPath) as! T
	}
	
	func dequeueReusableCell<T>(withIdentifier identifier: CellIdentifier) -> T where T: UITableViewCell {
		return self.dequeueReusableCell(withIdentifier: identifier.rawValue) as! T
	}
	
	#elseif canImport(AppKit)
	
	func dequeueReusableCell<T>(withIdentifier identifier: CellIdentifier, owner: Any? = nil) -> T where T: NSView {
		let itemIdentifier = NSUserInterfaceItemIdentifier(rawValue: identifier.rawValue)
		return self.makeView(withIdentifier: itemIdentifier, owner: owner) as! T
	}
	
	func register(_ nib: NSNib, forItemWith identifier: CellIdentifier) {
		let identifier = NSUserInterfaceItemIdentifier(rawValue: identifier.rawValue)
		self.register(nib, forIdentifier: identifier)
	}
	
	#endif
}

public extension CoreCellDequeuing where Self: CollectionView, CellIdentifier.RawValue == String {
	
	#if canImport(UIKit)
	
	func dequeueReusableCell<T>(withIdentifier identifier: CellIdentifier, for indexPath: IndexPath) -> T where T: UICollectionViewCell {
		return self.dequeueReusableCell(withReuseIdentifier: identifier.rawValue, for: indexPath) as! T
	}
	
	#elseif canImport(AppKit)
	
	func dequeueReusableCell<T>(withIdentifier identifier: CellIdentifier, for indexPath: IndexPath) -> T where T: NSCollectionViewItem {
		let itemIdentifier = NSUserInterfaceItemIdentifier(rawValue: identifier.rawValue)
		return self.makeItem(withIdentifier: itemIdentifier, for: indexPath) as! T
	}
	
	func register(_ nib: NSNib, forItemWith identifier: CellIdentifier) {
		let identifier = NSUserInterfaceItemIdentifier(rawValue: identifier.rawValue)
		self.register(nib, forItemWithIdentifier: identifier)
	}
	
	#endif
}

#endif
