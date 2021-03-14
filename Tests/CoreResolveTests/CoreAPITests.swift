//
//  CoreAPITests.swift
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

#if !os(watchOS)

import XCTest
@testable import CoreResolve

final class CoreAPITests: XCTestCase {
	
    func testOperationFinishes() throws {
		
		let container = setupStandardContainer()
		let operation = TestAPIOperation(urlString: "http://example.com/")
		
		MockURLProtocol.setDefaultRequestHandler()
		let finishExpectation = expectation(description: "Calls finish")
		
		operation.handleFinish = {
			finishExpectation.fulfill()
		}
		try container.addOperation(operation)
		
		wait(for: [finishExpectation], timeout: 5.0)
		XCTAssertNotNil(operation.operationError)
    }
	
	func testOperationCancels() throws {
		
		let container = setupStandardContainer()
		let operation = TestAPIOperation(urlString: "http://example.com/")
		
		MockURLProtocol.requestHandler = { request in
			operation.cancel()
			throw URLError(.cancelled)
		}
		let cancelExpectation = expectation(description: "Calls cancel")
		
		operation.handleCancel = {
			cancelExpectation.fulfill()
		}
		try container.addOperation(operation)
		
		wait(for: [cancelExpectation], timeout: 5.0)
		XCTAssertTrue(operation.isCancelled)
		XCTAssertNil(operation.operationError)
	}
	
	func setupStandardContainer() -> CoreAPIContainer {
		let configuration = URLSessionConfiguration.ephemeral
		configuration.protocolClasses = [MockURLProtocol.self]
		let session = URLSession(configuration: configuration)
		return CoreAPIContainer(with: TestAPIRequestProvider(), session: session)
	}
	
	func testGenerateRequestDataFailure() throws {
		
		let container = setupStandardContainer()
		let operation = TestAPIOperation(urlString: "ignored")
		operation.handleGenerateRequestData = nil // The default error will be thrown
		
		MockURLProtocol.setDefaultRequestHandler()
		let finishExpectation = expectation(description: "Calls finish")
		
		operation.handleFinish = {
			finishExpectation.fulfill()
		}
		try container.addOperation(operation)
		
		wait(for: [finishExpectation], timeout: 5.0)
		XCTAssertNotNil(operation.operationError)
		switch operation.operationError! {
		case MockCoreAPIOperationError.missingGenerateRequestDataHandler:
			break
		default:
			XCTFail("Unexpected operation error: \(operation.operationError!)")
		}
	}

	func testMakeRequestFailure() throws {
		
		let container = setupStandardContainer()
		let operation = TestAPIOperation(urlString: "bad url")
		
		MockURLProtocol.setDefaultRequestHandler()
		let finishExpectation = expectation(description: "Calls finish")
		
		operation.handleFinish = {
			finishExpectation.fulfill()
		}
		try container.addOperation(operation)
		
		wait(for: [finishExpectation], timeout: 5.0)
		XCTAssertNotNil(operation.operationError)
		switch operation.operationError! {
		case CoreAPIError.prepareRequestError(_):
			break
		default:
			XCTFail("Unexpected operation error: \(operation.operationError!)")
		}
	}
}

// MARK: - Work-in-progress concrete examples for API validation
fileprivate class TestAPIRequestProvider: CoreAPIRequestProviding {
	
	func provideRequest<APIRequest>(for type: APIRequest.Type) -> APIRequest where APIRequest: CoreAPIRequest {
		switch type {
		case is TestAPIRequest.Type:
			return TestAPIRequest() as! APIRequest
		default:
			fatalError()
		}
	}
}

fileprivate class TestAPIRequest: CoreAPIRequest {
	public typealias RequestDataType = String
	public typealias ResponseDataType = String
	
	public func makeRequest(from data: String) throws -> URLRequest {
		guard let url = URL(string: data) else {
			throw CoreAPIError.unexpectedError(nil)
		}
		return URLRequest(url: url)
	}
	
	public func parseResponse(data: Data) throws -> String {
		throw CoreAPIError.unexpectedError(nil)
	}
}

fileprivate class TestAPIOperation: MockCoreAPIOperation<TestAPIRequest> {
	
	let urlString: String

	required init(urlString: String) {
		self.urlString = urlString
		super.init()
		self.handleGenerateRequestData = { return urlString }
	}
	
	override public func processResponse(_ response: CoreAPIRequestTaskResult, completion: @escaping (Error?) -> Void) {
		switch response {
		case .success(_):
			completion(nil)
		case .failure(let error):
			completion(error)
		}
	}
}

#endif
