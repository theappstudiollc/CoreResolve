//
//  CoreAsynchronousOperationTests.swift
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

final class CoreAsynchronousOperationTests: XCTestCase {
    
	func testOperationMain() {
		// Make sure main() gets called
		let mainExpectation = expectation(description: "Calls main")
		
		let operation = BasicOperation(mainExpectation: mainExpectation)
		
		let operationQueue = OperationQueue()
		operationQueue.addOperation(operation)
		
		waitForExpectations(timeout: 5.0, handler: nil)
		XCTAssert(operation.finishClosures == nil)
	}
	
	func testOperationCancel() {
		// Cancel skips main, but still calls finish
		let finishExpectation = expectation(description: "Calls finish closure")
		let mainExpectation = expectation(description: "Does not call main")
		mainExpectation.isInverted = true
		
		let operation = BasicOperation(mainExpectation: mainExpectation)
		operation.addFinishClosure { _ in
			finishExpectation.fulfill()
		}
		operation.cancel()
		
		let operationQueue = OperationQueue()
		operationQueue.addOperation(operation)
		
		waitForExpectations(timeout: 1.0, handler: nil)
		XCTAssert(operation.isCancelled)
	}
    
    func testOperationFinishClosure() {
		// The closure passes in the finished operation as a parameter
		let finishExpectation = expectation(description: "Calls finish closure")
		
		let operation = BasicOperation()
		operation.addFinishClosure { sourceOperation in
			XCTAssert(sourceOperation === operation)
			finishExpectation.fulfill()
		}
		
		let operationQueue = OperationQueue()
		operationQueue.addOperation(operation)
		
		waitForExpectations(timeout: 5.0, handler: nil)
		// We expect the internal copy of the closures to be gone after finish() is performed
		XCTAssert(operation.finishClosures!.count == 0)
    }
	
	func testOperationDeinit() {
		// We expect the operation to deinit, even with the closure referencing the operation
		let deinitExpectation = expectation(description: "Calls deinit")
		let finishExpectation = expectation(description: "Calls finish closure")
		
		var operation: CoreAsynchronousOperation! = DeinitOperation(deinitExpectation: deinitExpectation)
		var operationReference = operation
		operation.addFinishClosure { sourceOperation in
			XCTAssert(sourceOperation === operationReference) // This captures a reference
			operationReference = nil
			finishExpectation.fulfill()
		}
		
		let operationQueue = OperationQueue()
		operationQueue.addOperation(operation)
		operation = nil
		
		waitForExpectations(timeout: 5.0, handler: nil)
	}
	
	func testOperationLinking() {
		// We expect the parameter to be assigned to operation2, which gets called after operation1
		let finishExpectation = expectation(description: "Calls finish closure")
		
		let operation2 = BasicOperation()
		let operation1 = BasicOperation(parameterValue: 1)
//		operation1.link(to: operation2) { sourceOperation, dependentOperation in
//			// We expect this to happen after operation1's main()
//			dependentOperation.parameter = sourceOperation.parameter
//		}
		operation1.link(to: operation2, performing: copyParameter)
		operation2.addFinishClosure { _ in
			operation1.parameter = 2
			finishExpectation.fulfill()
		}
		
		let operationQueue = OperationQueue()
		operationQueue.addOperation(operation2)
		operationQueue.addOperation(operation1)
		
		waitForExpectations(timeout: 5.0, handler: nil)
		XCTAssert(operation1.parameter == 2)
		XCTAssert(operation2.parameter == 1)
	}
	
	fileprivate func copyParameter(from source: BasicOperation, to dependent: BasicOperation) {
		// We expect this to happen after operation1's main()
		dependent.parameter = source.parameter
	}
}

// MARK: - Subject classes

fileprivate class TestOperation: CoreAsynchronousOperation {
	
	override func main() {
		finish()
	}
}

fileprivate class BasicOperation: ParameterOperation {
	
	weak var mainExpectation: XCTestExpectation?
	
	init(parameterValue: Int = 0, mainExpectation: XCTestExpectation? = nil) {
		self.mainExpectation = mainExpectation
		super.init(parameterValue: parameterValue)
	}
	
	override func main() {
		mainExpectation?.fulfill()
		super.main()
	}
}

fileprivate class DeinitOperation: TestOperation {
	
	weak var deinitExpectation: XCTestExpectation?
	
	init(deinitExpectation: XCTestExpectation? = nil) {
		self.deinitExpectation = deinitExpectation
		super.init()
	}
	
	deinit {
		deinitExpectation?.fulfill()
	}
}

fileprivate class ParameterOperation: TestOperation {
	
	public var parameter: Int = 0
	private var parameterValue: Int = 0
	
	init(parameterValue: Int) {
		self.parameterValue = parameterValue
		super.init()
	}
	
	override func main() {
		if parameter == 0, parameterValue != 0 {
			parameter = parameterValue
		}
		super.main()
	}
}

#endif
