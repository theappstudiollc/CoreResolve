//
//  MultipeerMessagePayload.swift
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

#if canImport(MultipeerConnectivity)

import Foundation

/// Encoded payload for MultipeerMessageManager
public struct MultipeerMessagePayload: Codable {
	
	/// The raw Data containing the message
	public let data: Data
	
	/// An optional URL referencing an associated resource
	public var resourceURL: URL?
	
	/// A unique identifier for the payload
	public let uuid: UUID
	
	/// A hard-coded version of the payload, to allow subsequent versions to decide what to do
	internal let version: Int = 1
	
	/// Initializes a new instance of the MultipeerMessagePayload given a Decoder instance. Currently, any future versions
	///
	/// - Parameter decoder: The instance with which to decode
	/// - Throws: Throws an error if data validation fails
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		let containerVersion = try container.decode(Int.self, forKey: .version)
		guard containerVersion == 1 else {
			throw DecodingError.dataCorruptedError(forKey: .version, in: container, debugDescription: "MultipeerMessagePayload version \(containerVersion) does not match the expected version \(version)")
		}
		self.data = try container.decode(Data.self, forKey: .data)
		self.resourceURL = try container.decodeIfPresent(URL.self, forKey: .resourceURL)
		self.uuid = try container.decode(UUID.self, forKey: .uuid)
	}
	
	/// Initializes a new instance of the MultipeerMessagePayload with its values for `data` and `resourceURL`
	///
	/// - Parameters:
	///   - data: The raw Data containing the message
	///   - at: An uptional URL referencing an associated resource
	public init(with data: Data, resource at: URL?) {
		self.data = data
		self.resourceURL = at
		uuid = UUID()
	}
}

#endif
