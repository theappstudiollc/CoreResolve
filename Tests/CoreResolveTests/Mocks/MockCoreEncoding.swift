//
//  MockCoreEncoding.swift
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

public enum MockCoreEncodingError: Error {
	
	case forcedError
}

public class MockCoreEncoding {
	
	public enum EncodingResult {
		case throwError(error: Error)
		case returnData(data: Data)
		case useCoreEncoding(encoder: CoreEncoding)
	}
	
	public let encodingResult: EncodingResult
	
	public init(encodingResult: EncodingResult) {
		self.encodingResult = encodingResult
	}
}

extension MockCoreEncoding: CoreEncoding {
	
	public func encode<T>(_ value: T) throws -> Data where T: Encodable {
		switch encodingResult {
		case .throwError(let error):
			throw error
		case .returnData(let data):
			return data
		case .useCoreEncoding(let encoder):
			return try encoder.encode(value)
		}
	}
}
