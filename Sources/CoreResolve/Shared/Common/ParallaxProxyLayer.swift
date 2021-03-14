//
//  ParallaxProxyLayer.swift
//  CoreResolve
//
//  Created by David Mitchell
//  Copyright © 2018 The App Studio LLC.
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

#if canImport(QuartzCore)

import QuartzCore

/// Defines an object that supports Parallax
@objc public protocol Parallaxable {
	
	/// The amount of shift with which to apply the Parallax effect
	var parallaxShift: CGVector { get set }
}

/// A CALayer that supports the Parallaxable protocol
public final class ParallaxProxyLayer: CALayer, Parallaxable {
	
	/// The amount of shift with which to apply the Parallax effect
	public var parallaxShift: CGVector = .zero {
		didSet {
			if let shift = parallaxableObject?.parallaxShift, shift != parallaxShift {
				parallaxableObject?.parallaxShift = parallaxShift
			}
		}
	}
	
	/// A Parallaxable object to forward parallaxShift adjustments to
	@IBOutlet public weak var parallaxableObject: Parallaxable? {
		didSet {
			if let shift = parallaxableObject?.parallaxShift {
				parallaxShift = shift
			}
		}
	}
	
	/// Initializes a new instance of the ParallaxProxyLayer. Used by CoreAnimation to create shadow copies of a layer in animation
	///
	/// - Parameter layer: A layer used as the source
	public override init(layer: Any) {
		if let parallaxableLayer = layer as? ParallaxProxyLayer {
			parallaxableObject = parallaxableLayer.parallaxableObject
			parallaxShift = parallaxableLayer.parallaxShift
		}
		super.init(layer: layer)
	}
	
	/// Initializes a new instance of the ParallaxProxyLayer
	///
	/// - Parameter aDecoder: The NSCoder which contains the configuration for the resulting instance
	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	/// Overrides CALayer needsDisplay(forKey:)
	///
	/// - Parameter key: The key to examine
	/// - Returns: Whether changes to this key require redrawing
	public override class func needsDisplay(forKey key: String) -> Bool {
		if key == #keyPath(parallaxShift) {
			return true
		}
		return super.needsDisplay(forKey: key)
	}
}

#endif
