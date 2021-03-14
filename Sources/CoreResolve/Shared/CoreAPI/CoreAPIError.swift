//
//  CoreAPIError.swift
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

/// Error describing the reason for failures to interact with a remote API
///
/// - httpError: The server returned data, but with an HTTP status code outside of the range 200-299
/// - invalidOperation: The API Request Task is in an invalid state for the requested call, such as having performRequest called multiple times
/// - prepareRequestError: The API Request is unable to generate a URLRequest based on the input. The underlying error is provided for convenience
/// - sessionError: The URLSession was unable to fulfill the request. The underlying error is provided for convenience, if available
/// - parseResponseError: The API Request is unable to parse the remote API response. The underlying error is provided for convenience, if available
/// - unexpectedError: The remote API provided neither Data nor an Error. The URLResponse is provided, if available
public enum CoreAPIError: Error {
	
	case httpError(_: Data, _: HTTPURLResponse)
	
	case invalidOperation
	
	case prepareRequestError(_: Error)
	
	case sessionError(_: Error, _: URLResponse?)
	
	case parseResponseError(_: Error, _: URLResponse?)
	
	case unexpectedError(_: URLResponse?)
}

extension CoreAPIError: LocalizedError {
	
	public var errorDescription: String? {
		return NSLocalizedString("\(self).errorDescription", tableName: "CoreAPIError", bundle: Bundle(for: CoreAPIContainer.self), comment: "\(self)")
	}
}
