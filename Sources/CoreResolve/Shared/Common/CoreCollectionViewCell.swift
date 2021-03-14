//
//  CoreCollectionViewCell.swift
//  CoreResolve
//
//  Created by David Mitchell
//  Copyright © 2020 The App Studio LLC.
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

// NOTE: The order of these #if statements matter, in order to support all platforms + Interface Builder + deployment scenarios

#if !os(watchOS)

#if os(iOS) || os(tvOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

#if TARGET_INTERFACE_BUILDER || targetEnvironment(simulator)

// TODO: Why does this need to be backwards from CoreViewController #if statements to support Interface Builder?
#if os(macOS)

open class CoreCollectionViewCell: NSCollectionViewItem { }

#elseif os(iOS) || os(tvOS)

open class CoreCollectionViewCell: UICollectionViewCell { }

#endif

#elseif DEBUG

/// Core collection view cell, that enables CorePrintsSupporting capabilities in DEBUG mode
open class CoreCollectionViewCell: CollectionViewCell, CorePrintsSupporting {
	
	override open func prepareForReuse() {
		super.prepareForReuse()
		guard self is CorePrintsViewLifecycle else { return }
		LogManager.viewLifecycle.debug("%{public}@ prepareForReuse()", debugDescription)
	}
}

#else // Production builds should just typealias so that we remove a layer in the class hierarchy

public typealias CoreCollectionViewCell = CollectionViewCell

#endif

#endif
