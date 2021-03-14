//
//  MockURLProtocol.swift
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

public class MockURLProtocol: URLProtocol {
	
	public typealias RequestHandler = ((URLRequest) throws -> (HTTPURLResponse, Data))
	
	public static var requestHandler: RequestHandler? = defaultRequestHandler
	
	override public class func canInit(with request: URLRequest) -> Bool {
		return true
	}
	
	override public class func canonicalRequest(for request: URLRequest) -> URLRequest {
		return request
	}
	
	override public func startLoading() {
		let handler = MockURLProtocol.requestHandler ?? MockURLProtocol.defaultRequestHandler
		do {
			let (response, data) = try handler(request)
			client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
			client?.urlProtocol(self, didLoad: data)
			client?.urlProtocolDidFinishLoading(self)
		} catch {
			client?.urlProtocol(self, didFailWithError: error)
		}
	}
	
	override public func stopLoading() {
		
	}
	
	public static func setDefaultRequestHandler() {
		requestHandler = defaultRequestHandler
	}
	
	static let defaultRequestHandler: RequestHandler = { request in
		return (HTTPURLResponse(url: request.url!, mimeType: nil, expectedContentLength: 0, textEncodingName: nil), Data())
	}
}
