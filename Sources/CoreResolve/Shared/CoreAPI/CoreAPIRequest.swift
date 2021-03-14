//
//  CoreAPIRequest.swift
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

/// Protocol for interacting with a remote API
public protocol CoreAPIRequest {
	
	/// The input data type this request uses to generate a URLRequest
	associatedtype RequestDataType
	
	// The output data type provided by this request
	associatedtype ResponseDataType
	
	/// Makes a URLRequest from the input data
	///
	/// - Parameter data: The input data type
	/// - Returns: A URLRequest that may be used with an URLSession to interact with the remote API
	/// - Throws: An Error if the input RequestDataType cannot be used to generate a valid URLRequest
	func makeRequest(from data: RequestDataType) throws -> URLRequest
	
	/// Parses the URLSession response to return the output data type
	///
	/// - Parameter data: The Data provided by the URLSessionTask
	/// - Returns: The output data type
	/// - Throws: An Error if the data cannot be transformed into the ResponseDataType
	func parseResponse(data: Data) throws -> ResponseDataType
}
