//
//  Extensions-SceneKit.swift
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

#if canImport(SceneKit)

import SceneKit

public extension SCNVector3 {
	
	static func - (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
		return SCNVector3(left.x - right.x, left.y - right.y, left.z - right.z)
	}
	
	static func + (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
		return SCNVector3(left.x + right.x, left.y + right.y, left.z + right.z)
	}
	/*
	static func / (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
		return SCNVector3(left.x / right.x, left.y / right.y, left.z / right.z)
	}
	
	static func * (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
		return SCNVector3(left.x * right.x, left.y * right.y, left.z * right.z)
	}
	*/
	func length() -> Float {
		return sqrtf(powf(Float(x), 2) + powf(Float(y), 2) + powf(Float(z), 2))
	}
	
	#if !targetEnvironment(macCatalyst) && !os(watchOS)
	
	func multiplied(byRotation rotation: SCNVector4, withRadianAdjustment adjustment: Float) -> SCNVector3 {
		let shiftedRotation = Float(rotation.w) + adjustment
		if shiftedRotation == 0 {
			return self
		}
		let gPosition = SCNVector3ToGLKVector3(self)
		let gRotation = GLKMatrix4MakeRotation(shiftedRotation, Float(rotation.x), Float(rotation.y), Float(rotation.z))
		let vector = GLKMatrix4MultiplyVector3(gRotation, gPosition)
		return SCNVector3FromGLKVector3(vector)
	}
	
	#endif
}

#endif
