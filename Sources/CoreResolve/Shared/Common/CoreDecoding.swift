//
//  CoreDecoding.swift
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

import Foundation

/// Protocol for decoding Decodable items, allowing unit tests
public protocol CoreDecoding {
	
	/// Decodes a Decodable type from Data
	///
	/// - parameter type: The type of the value to decode
	/// - parameter data: The data to decode from
	/// - returns: A value of the requested type
	/// - throws: An error if any value throws an error during decoding.
	func decode<T>(_ type: T.Type, from data: Data) throws -> T where T: Decodable
}

// MARK: - CoreDecoding support for JSONDecoder
extension JSONDecoder: CoreDecoding { }
