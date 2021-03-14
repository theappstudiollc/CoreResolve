//
//  ResolvedServiceReference.swift
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

/// Wraps a resolved service in a struct that we can store in a Set and compare later
internal struct ResolvedServiceReference {
	
	/// Initializes a new instance of the ResolvedServiceReference struct
	///
	/// - Parameter service: A service that this struct will contain
	init(_ service: Any) {
		self.service = service
	}
	
	internal let service: Any
}

/// Implementation of the Equatable protocol
extension ResolvedServiceReference: Equatable {
	
	static func == (left: ResolvedServiceReference, right: ResolvedServiceReference) -> Bool {
		switch (left.service, right.service) {
		case (let leftClass as AnyObject, let rightClass as AnyObject):
			return leftClass === rightClass
		default:
			return type(of: left) == type(of: right)
		}
	}
}

/// Implementation of the Hashable protocol
extension ResolvedServiceReference: Hashable {
	
	public func hash(into hasher: inout Hasher) {
		hasher.combine("\(service)")
	}
}
