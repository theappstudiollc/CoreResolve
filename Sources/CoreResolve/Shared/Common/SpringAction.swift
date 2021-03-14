//
//  SpringAction.swift
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

import SpriteKit

public extension SKAction {
	
	/// Provides a spring action to apply to an SKNode using a mass-spring-damping timing function
	///
	/// - Parameters:
	///   - duration: The duration of the spring action
	///   - startValue: The start value of the effect
	///   - endValue: The end value of the effect
	///   - numberOfBounces: The number of bounces
	///   - block: An action block receiving the results of the timing-function
	/// - Returns: Returns the SKAction that may be used on an SKNode
	class func springAction(withDuration duration: TimeInterval, startingAt startValue: CGFloat, endingAt endValue: CGFloat, numberOfBounces: Int, actionBlock block: @escaping (_ node: SKNode, _ elapsedTime: CGFloat, _ currentValue: CGFloat) -> Void) -> SKAction {
		
		// Use a mass-spring-damping timingFunction: y = A * e^(-alpha*t)*cos(omega*t)
		let coefficient = startValue - endValue
		var start = log2(1 / abs(coefficient))
		if start.isNaN || start.isInfinite {
			// In this unexpected case we always return the ending value
			return SKAction.customAction(withDuration: duration) { (node: SKNode, elapsedTime: CGFloat) in
				block(node, elapsedTime, endValue)
			}
		} else if start > 0 {
			start.negate()
		}
		let numberOfPeriods = CGFloat(numberOfBounces) / 2.0 + 0.5
		let stop = numberOfPeriods * 2.0 * .pi
		
		return SKAction.customAction(withDuration: duration) { (node: SKNode, elapsedTime: CGFloat) in
			let percentComplete = elapsedTime / CGFloat(duration)
			let currentValue = coefficient * pow(CGFloat(M_E), start * percentComplete) * cos(stop * percentComplete) + endValue
			block(node, elapsedTime, currentValue)
		}
	}
}
