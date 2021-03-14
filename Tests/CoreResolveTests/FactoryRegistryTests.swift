//
//  FactoryRegistryTests.swift
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

final class FactoryRegistryTests: XCTestCase {
	
	func testNilConstructor() {
		let factoryRegistry = FactoryRegistry()
		factoryRegistry.registerFactory(withIdentifier: FactoryA.FactoryIdentifier) { FactoryA() }
		XCTAssertNoThrow(try factoryRegistry.invokeFactory(withIdentifier: FactoryA.FactoryIdentifier))
	}
	
	func testFactoryRegistered() throws {
		let factoryRegistry = standardInitialization()
		let resolvedA = try factoryRegistry.invokeFactory(withIdentifier: FactoryA.FactoryIdentifier)
		XCTAssertNotNil(resolvedA)
		XCTAssert(resolvedA is FactoryA)
	}
	
	func testFactoryAlias() throws {
		// Add an alias which maps to an existing factory mapping -- we'll prove that FactoryRegistry can get to it
		let factoryRegistry = standardInitialization()
		factoryRegistry.registerFactory(withIdentifier: FactoryA.AlternateIdentifier) {
			try! factoryRegistry.invokeFactory(withIdentifier: FactoryA.FactoryIdentifier)
		}
		let resolvedA1 = try factoryRegistry.invokeFactory(withIdentifier: FactoryA.FactoryIdentifier)
		XCTAssertNotNil(resolvedA1)
		let resolvedA2 = try factoryRegistry.invokeFactory(withIdentifier: FactoryA.AlternateIdentifier)
		XCTAssertNotNil(resolvedA2)
		XCTAssert(type(of: resolvedA1) == type(of: resolvedA2))
	}
	
	func testFactoryInitFailure() {
		let factoryRegistry = standardInitialization()
		do {
			_ = try factoryRegistry.invokeFactory(withIdentifier: FactoryB.FactoryIdentifier)
			XCTFail("FactoryInvoking should fail")
		} catch CoreResolve.CoreFactoryServiceError.initializationFailure(let underlyingError) {
			guard case FactoryB.FactoryBError.initializationError = underlyingError else {
				XCTFail("Unexpected underlying error: \(underlyingError)")
				return
			}
		} catch {
			XCTFail("FactoryInvoking should fail with different exception: \(error)")
		}
	}
	
	func testFactoryNotRegistered() {
		let factoryRegistry = standardInitialization()
		XCTAssertThrowsError(try factoryRegistry.invokeFactory(withIdentifier: FactoryC.FactoryIdentifier)) { (error) -> Void in
//			XCTAssert(CoreResolve.CoreFactoryServiceError.unmappedFactory == error, "Unexpected error: \(error)")
			guard case CoreResolve.CoreFactoryServiceError.unregisteredFactory = error else {
				XCTFail("Unexpected error: \(error)")
				return
			}
		}
	}
	
	func testFactoryUniqueness() throws {
		let factoryRegistry = standardInitialization()
		let resolvedA1 = try factoryRegistry.invokeFactory(withIdentifier: FactoryA.FactoryIdentifier)
		XCTAssertNotNil(resolvedA1)
		let resolvedA2 = try factoryRegistry.invokeFactory(withIdentifier: FactoryA.FactoryIdentifier)
		XCTAssertNotNil(resolvedA2)
		switch (resolvedA1, resolvedA2) {
		case (let leftClass as AnyObject, let rightClass as AnyObject):
			XCTAssert(leftClass !== rightClass)
		default:
			XCTAssert(type(of: resolvedA1) != type(of: resolvedA2))
		}
	}
	
	func standardInitialization() -> FactoryRegistry {
		return FactoryRegistry(withFactoryMappings: [
			FactoryA.FactoryIdentifier: { FactoryA() },
			FactoryB.FactoryIdentifier: { try FactoryB() },
		])
	}
}

// MARK: - Subject classes

fileprivate class FactoryA {
	
	private static var internalInstanceCount: Int = 0
	let instanceCount: Int
	
	init() {
		FactoryA.internalInstanceCount += 1
		instanceCount = FactoryA.internalInstanceCount
	}
	
	class var FactoryIdentifier: FactoryRegistry.FactoryIdentifier {
		return "\(FactoryA.self)"
	}
	
	class var AlternateIdentifier: FactoryRegistry.FactoryIdentifier {
		return "Alt\(FactoryA.self)"
	}
}

fileprivate class FactoryB {
	
	public enum FactoryBError: Error {
		case initializationError
	}
	
	init() throws {
		throw FactoryBError.initializationError
	}
	
	class var FactoryIdentifier: FactoryRegistry.FactoryIdentifier {
		return "\(FactoryB.self)"
	}
}

fileprivate class FactoryC {
	
	class var FactoryIdentifier: FactoryRegistry.FactoryIdentifier {
		return "\(FactoryC.self)"
	}
}

#endif
