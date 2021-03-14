//
//  MockCoreDecoding.swift
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

import CoreResolve
import Foundation

public enum MockCoreDecodingError: Error {
	
	case forcedError
}

public class MockCoreDecoding {
	
	public enum DecodingResult {
		case throwError(error: Error)
		case useCoreDecoding(decoder: CoreDecoding)
	}
	
	public let decodingResult: DecodingResult
	
	public init(decodingResult: DecodingResult) {
		self.decodingResult = decodingResult
	}
}

extension MockCoreDecoding: CoreDecoding {
	
	public func decode<T>(_ type: T.Type, from data: Data) throws -> T where T: Decodable {
		switch decodingResult {
		case .throwError(let error):
			throw error
		case .useCoreDecoding(let decoder):
			return try decoder.decode(type, from: data)
		}
	}
}
