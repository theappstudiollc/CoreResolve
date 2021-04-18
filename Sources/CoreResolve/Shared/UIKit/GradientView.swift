//
//  GradientView.swift
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

#if canImport(UIKit) && canImport(QuartzCore)

import QuartzCore
import UIKit

/// A CAGradientLayer-backed UIView that can also render in Interface Builder
@IBDesignable public final class GradientView: UIView {
	
	// MARK: - Interface Builder properties
	
    /// The direction of the gradient
	@IBInspectable public var gradientDirection: GradientDirection = .vertical {
		didSet { updateDirection() }
	}
	
    /// The end color of the gradient
	@IBInspectable public var endColor: UIColor! {
		didSet { updateColors() }
	}
	
    /// The start color of the gradient
	@IBInspectable public var startColor: UIColor! {
		didSet { updateColors() }
	}
	
	// MARK: - UIView overrides
	
	public override class var layerClass: AnyClass {
		return CAGradientLayer.self
	}
	
	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		updateDirection()
		updateColors()
	}
	
	public override init(frame: CGRect) {
		super.init(frame: frame)
		updateDirection()
		updateColors()
	}
	
	// MARK: - Public types
	
    /// Enum specifying the direction of the gradient
    ///
    /// - horizontal: Specifies a horizontal gradient
    /// - vertical: Specifies a vertical gradient
    @objc public enum GradientDirection: Int {
		case horizontal = 0
		case vertical
	}
	
	// MARK: - Private methods
	
	func updateColors() {
		let gradientLayer = layer as! CAGradientLayer
		let startCgColor = (startColor ?? UIColor.white).cgColor
		let endCgColor = (endColor ?? UIColor.white).cgColor
		gradientLayer.colors = [startCgColor, endCgColor]
	}
	
	func updateDirection() {
		let gradientLayer = layer as! CAGradientLayer
		switch gradientDirection {
		case .horizontal:
			gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
			gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
		case .vertical:
			gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
			gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
		}
	}
}

#endif
