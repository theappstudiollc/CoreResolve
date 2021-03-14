//
//  ServiceManagerTests.swift
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

final class ServiceManagerTests: XCTestCase {
	
	func testNilConstructor() {
		let serviceManager = ServiceManager()
		serviceManager.registerService(withIdentifier: ServiceA.ServiceIdentifier) { ServiceA() }
		XCTAssertNoThrow(try serviceManager.resolveService(withIdentifier: ServiceA.ServiceIdentifier))
	}
	
	func testServiceRegistered() throws {
		let serviceManager = standardInitialization()
		let resolvedA = try serviceManager.resolveService(withIdentifier: ServiceA.ServiceIdentifier)
		XCTAssert(resolvedA is ServiceA)
		XCTAssert(serviceManager.resolvedServiceReferences.contains(where: {
			guard let service = $0.service as? ServiceA else { return false }
			switch (service, resolvedA) {
			case (let leftClass as AnyObject, let rightClass as AnyObject):
				return leftClass === rightClass
			default:
				return type(of: service) == type(of: resolvedA)
			}
		}))
	}
	
	func testServiceAlias() throws {
		// Add an alias which maps to an existing service registration -- we'll prove that ServiceManager can get to it
		let serviceManager = standardInitialization()
		serviceManager.registerService(withIdentifier: ServiceA.AlternateIdentifier) {
			try! serviceManager.resolveService(withIdentifier: ServiceA.ServiceIdentifier)
		}
		let resolvedA1 = try serviceManager.resolveService(withIdentifier: ServiceA.ServiceIdentifier)
		XCTAssertNotNil(resolvedA1)
		let resolvedA2 = try serviceManager.resolveService(withIdentifier: ServiceA.AlternateIdentifier)
		switch (resolvedA1, resolvedA2) {
		case (let leftClass as AnyObject, let rightClass as AnyObject):
			XCTAssert(leftClass === rightClass)
		default:
			XCTAssert(type(of: resolvedA1) == type(of: resolvedA2))
		}
		XCTAssert(serviceManager.resolvedServiceReferences.count == 1)
	}
	
	func testServiceInitFailure() {
		let serviceManager = standardInitialization()
		do {
			_ = try serviceManager.resolveService(withIdentifier: ServiceB.ServiceIdentifier)
			XCTFail("ServiceResolution should fail")
		} catch CoreResolve.CoreServiceProvidingError.initializationFailure(let underlyingError) {
			guard case ServiceB.ServiceBError.initializationError = underlyingError else {
				XCTFail("Unexpected underlying error: \(underlyingError)")
				return
			}
		} catch {
			XCTFail("ServiceResolution should fail with different exception: \(error)")
		}
	}

	func testServiceNotRegistered() {
		let serviceManager = standardInitialization()
		XCTAssertThrowsError(try serviceManager.resolveService(withIdentifier: ServiceC.ServiceIdentifier)) { (error) -> Void in
			guard case CoreResolve.CoreServiceProvidingError.unregisteredService = error else {
				XCTFail("Unexpected error: \(error)")
				return
			}
		}
//		do {
//			_ = try serviceManager.resolveService(withIdentifier: ServiceC.ServiceIdentifier)
//			XCTFail("ServiceResolution should fail")
//		} catch CoreResolve.CoreServiceProvidingError.unregisteredService {
//			XCTAssertTrue(true)
//		} catch {
//			XCTFail("ServiceResolution should fail with different exception")
//		}
	}

	func testServiceReuse() throws {
		let serviceManager = standardInitialization()
		let resolvedA1 = try serviceManager.resolveService(withIdentifier: ServiceA.ServiceIdentifier)
		XCTAssertNotNil(resolvedA1)
		let resolvedA2 = try serviceManager.resolveService(withIdentifier: ServiceA.ServiceIdentifier)
		XCTAssertNotNil(resolvedA2)
		switch (resolvedA1, resolvedA2) {
		case (let leftClass as AnyObject, let rightClass as AnyObject):
			XCTAssert(leftClass === rightClass)
		default:
			XCTAssert(type(of: resolvedA1) == type(of: resolvedA2))
		}
		XCTAssert(serviceManager.resolvedServiceReferences.count == 1)
	}
	
	func testServiceRetain() throws {
		let serviceManager = standardInitialization()
		let resolvedA1 = try serviceManager.resolveService(withIdentifier: ServiceA.ServiceIdentifier)
		XCTAssertNotNil(resolvedA1)
		serviceManager.releaseUnusedServices()
		XCTAssert(serviceManager.resolvedServiceReferences.count == 0)
		let resolvedA2 = serviceManager.resolveServiceIfLoaded(withIdentifier: ServiceA.ServiceIdentifier)
		XCTAssertNotNil(resolvedA2)
		switch (resolvedA1, resolvedA2) {
		case (let leftClass as AnyObject, let rightClass as AnyObject):
			XCTAssert(leftClass === rightClass)
		default:
			XCTAssert(type(of: resolvedA1) == type(of: resolvedA2))
		}
	}
	
	func testServiceRelease() {
		let serviceManager = standardInitialization()
		var resolvedA1: ServiceA?
		XCTAssertNoThrow(resolvedA1 = try serviceManager.resolveService(withIdentifier: ServiceA.ServiceIdentifier) as? ServiceA)
		XCTAssertNotNil(resolvedA1)
		let instanceA1 = resolvedA1!.instanceCount
		resolvedA1 = nil
		serviceManager.releaseUnusedServices()
		XCTAssert(serviceManager.resolvedServiceReferences.count == 0)
		// Now re-request ServiceA and ensure the pointers are not the same
		var resolvedA2: ServiceA?
		XCTAssertNoThrow(resolvedA2 = try serviceManager.resolveService(withIdentifier: ServiceA.ServiceIdentifier) as? ServiceA)
		XCTAssertNotNil(resolvedA2)
		let instanceA2 = resolvedA2!.instanceCount
		XCTAssert(instanceA1 != instanceA2)
	}
	
	func standardInitialization() -> ServiceManager {
		return ServiceManager(withServiceInitializers: [
			ServiceA.ServiceIdentifier: { ServiceA() },
			ServiceB.ServiceIdentifier: { try ServiceB() },
		])
	}
}

// MARK: - Subject classes

fileprivate class ServiceA {
	
	private static var internalInstanceCount: Int = 0
	let instanceCount: Int
	
	init() {
		ServiceA.internalInstanceCount += 1
		instanceCount = ServiceA.internalInstanceCount
	}
	
	class var ServiceIdentifier: ServiceManager.ServiceIdentifier {
		return "\(ServiceA.self)"
	}
	
	class var AlternateIdentifier: ServiceManager.ServiceIdentifier {
		return "Alt\(ServiceA.self)"
	}
}

fileprivate class ServiceB {
	
	public enum ServiceBError: Error {
		case initializationError
	}

	init() throws {
		throw ServiceBError.initializationError
	}
	
	class var ServiceIdentifier: ServiceManager.ServiceIdentifier {
		return "\(ServiceB.self)"
	}
}

fileprivate class ServiceC {
	
	class var ServiceIdentifier: ServiceManager.ServiceIdentifier {
		return "\(ServiceC.self)"
	}
}

#endif
