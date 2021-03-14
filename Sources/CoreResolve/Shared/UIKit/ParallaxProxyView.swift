//
//  ParallaxProxyView.swift
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

#if canImport(UIKit) && !os(watchOS)

import UIKit

/// A UIView that forwards UIMotionEffects to a Parallaxable object
public final class ParallaxProxyView: UIView {
	
	// MARK: - UIView overrides
	
	override public class var layerClass: AnyClass {
		return ParallaxProxyLayer.self
	}
	
	// MARK: - Public properties and methods
	
    /// Applies x and y motion effects to the view, which get passed onto the parallaxableObject. Positive values for xRange and yRange will make the object appear that it is above the screen. Use negative values to make them appear below
    ///
    /// - Parameters:
    ///   - xRange: The UIMotionEffect range along the x-axis
    ///   - yRange: The UIMotionEffect range along the y-axis
	///   - parallaxable: The Parallaxable instance with which to apply the UIMotionEffect
	public func forwardMotionEffect(withXRange xRange: CGFloat, yRange: CGFloat, toParallaxableObject parallaxable: Parallaxable? = nil) {
		if let parallaxable = parallaxable {
			parallaxableObject = parallaxable
		}
		motionEffects = [ParallaxInterpolatingMotionEffect(withXRange: xRange, yRange: yRange)]
	}
	
    /// The Parallaxable object that UIMotionEffects are forwarded to
	public var parallaxableObject: Parallaxable? {
		get {
			return parallaxProxyLayer.parallaxableObject
		}
		set {
			parallaxProxyLayer.parallaxableObject = newValue
		}
	}
	
	// MARK: - Private properties and methods
	
	private var parallaxProxyLayer: ParallaxProxyLayer {
		return layer as! ParallaxProxyLayer
	}
}

fileprivate class ParallaxInterpolatingMotionEffect: UIMotionEffect {
	
	private var xRange: CGFloat
	private var yRange: CGFloat
	
	required init(withXRange xRange: CGFloat, yRange: CGFloat) {
		self.xRange = xRange
		self.yRange = yRange
		super.init()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func keyPathsAndRelativeValues(forViewerOffset viewerOffset: UIOffset) -> [String : Any]? {
		return ["parallaxShift" : CGVector(dx: xRange * viewerOffset.horizontal, dy: -yRange * viewerOffset.vertical)]
	}
}

#endif
