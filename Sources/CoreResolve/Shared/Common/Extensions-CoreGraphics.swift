//
//  Extensions-CoreGraphics.swift
//  CoreResolve
//
//  Created by David Mitchell
//  Copyright © 2017 The App Studio LLC.
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

import CoreGraphics
#if os(iOS) || os(tvOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

public extension CGAffineTransform {
	
	var xScale: CGFloat {
		return sqrt(pow(a, 2) + pow(c, 2))
	}
	
	var yScale: CGFloat {
		return sqrt(pow(b, 2) + pow(d, 2))
	}
}

public extension CGPoint {
	
	static prefix func - (input: CGPoint) -> CGPoint {
		return CGPoint(x: -input.x, y: -input.y)
	}
	
	static func - (left: CGPoint, right: CGPoint) -> CGPoint {
		return CGPoint(x: left.x - right.x, y: left.y - right.y)
	}
	
	static func + (left: CGPoint, right: CGPoint) -> CGPoint {
		return CGPoint(x: left.x + right.x, y: left.y + right.y)
	}
	
	static func * (left: CGPoint, right: CGFloat) -> CGPoint {
		return CGPoint(x: left.x * right, y: left.y * right)
	}
	
	static func / (left: CGPoint, right: CGFloat) -> CGPoint {
		return CGPoint(x: left.x / right, y: left.y / right)
	}
	
	func bounded(in rect: CGRect) -> CGPoint {
		return CGPoint(x: self.x.bounded(by: rect.minX...rect.maxX), y: self.y.bounded(by: rect.minY...rect.maxY))
	}
}

public extension CGSize {
	
	static func * (left: CGSize, right: CGFloat) -> CGSize {
		return CGSize(width: left.width * right, height: left.height * right)
	}
	
	static func * (left: CGSize, right: CGVector) -> CGSize {
		return CGSize(width: left.width * right.dx, height: left.height * right.dy)
	}
	
	static func / (left: CGSize, right: CGFloat) -> CGSize {
		return CGSize(width: left.width / right, height: left.height / right)
	}
	
	#if os(iOS) || os(macOS) || os(tvOS)
	static var noIntrinsicSize: CGSize {
		#if os(macOS)
		return CGSize(width: NSView.noIntrinsicMetric, height: NSView.noIntrinsicMetric)
		#else
		return CGSize(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric)
		#endif
	}
	#endif
}

public extension CGRect {
	
	init(topLeft: CGPoint, bottomRight: CGPoint) {
		let size = CGSize(width: bottomRight.x - topLeft.x, height: bottomRight.y - topLeft.y)
		self.init(origin: topLeft, size: size)
	}
	
	var bottomRight: CGPoint {
		return CGPoint(x: maxX, y: maxY)
	}
	
	var center: CGPoint {
		return CGPoint(x: midX, y: midY)
	}
	
	var topLeft: CGPoint {
		return CGPoint(x: minX, y: minY)
	}
}

public extension CGVector {
	
	init(fromPoint point: CGPoint, aboutOrigin origin: CGPoint? = .zero) {
		self.init(dx: point.x - origin!.x, dy: point.y - origin!.y)
	}
	
	func length() -> CGFloat {
		return sqrt(pow(dx, 2) + pow(dy, 2))
	}
}
