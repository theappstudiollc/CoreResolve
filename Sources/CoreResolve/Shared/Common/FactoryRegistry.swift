//
//  FactoryRegistry.swift
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

/// Provides access to class factories via an identifier
public final class FactoryRegistry {
	
	/// It's your job to decide what type FactoryIdentifier should be -- and always stick to it
	public typealias FactoryIdentifier = AnyHashable
	/// You are free to use a closure that calls your own custom closure (containing any arguments you think are necessary)
	public typealias FactoryClosure = () throws -> Any
	
	// MARK: - Public properties and methods
	
	/// Initializes the FactoryRegistry with an optional Dictionary of factory mappings
	///
	/// - Parameter factoryMappings: An optional Dictionary of factories keyed by their FactoryIdentifier
	public required init(withFactoryMappings factoryMappings: [FactoryIdentifier : FactoryClosure]? = nil) {
		if let mappings = factoryMappings {
			self.factoryMappings = mappings
		} else {
			self.factoryMappings = Dictionary(minimumCapacity: 16)
		}
	}
	
	/// Registers a factory for a given FactoryIdentifier
	///
	/// - Parameters:
	///   - factoryIdentifier: The FactoryIdentifier for which to register the factory
	///   - factory: The closure that will manufacture objects when invoked
	public func registerFactory(withIdentifier factoryIdentifier: FactoryIdentifier, factory: @escaping FactoryClosure) {
		factoryMappings[factoryIdentifier] = factory
	}
	
	/// Invokes a factory by its registered FactoryIdentifier and returns the object
	///
	/// - Parameter factoryIdentifier: The FactoryIdentifier for which to make an object
	/// - Returns: Returns the requested object
	/// - Throws: Throws a CoreFactoryServiceError or Foundation error if encountered
	public func invokeFactory(withIdentifier factoryIdentifier: FactoryIdentifier) throws -> Any {
		guard let factoryClosure = factoryMappings[factoryIdentifier] else {
			throw CoreFactoryServiceError.unregisteredFactory
		}
		do {
			return try factoryClosure()
		} catch {
			throw CoreFactoryServiceError.initializationFailure(underlyingError: error)
		}
	}
	
	// MARK: - Private properties and methods
	
	internal var factoryMappings: [FactoryIdentifier : FactoryClosure] // Marked internal so that peer classes can examine this
}
