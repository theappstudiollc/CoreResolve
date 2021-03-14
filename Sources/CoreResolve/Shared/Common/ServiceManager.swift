//
//  ServiceManager.swift
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

/// Resolves services on demand and manages their lifetime
public final class ServiceManager {
	
	/// It's your job to decide what type ServiceIdentifier should be -- and always stick to it
	public typealias ServiceIdentifier = FactoryRegistry.FactoryIdentifier
	
	/// You are free to use a closure that calls your own custom closure (containing any arguments you think are necessary)
	public typealias ServiceInitializer = () throws -> Any
	
	// MARK: - Public properties and methods
	
	/// Initializes the ServiceManager with an optional Dictionary of service initializers
	///
	/// - Parameter serviceInitializers: An optional Dictionary of service initializers keyed by their ServiceIdentifier
	public required init(withServiceInitializers serviceInitializers: [ServiceIdentifier : ServiceInitializer]? = nil) {
		self.factoryRegistry = FactoryRegistry(withFactoryMappings: serviceInitializers)
		let initialCapacity = factoryRegistry.factoryMappings.capacity
		self.resolvedServices = Dictionary(minimumCapacity: initialCapacity)
		self.resolvedServiceReferences = Set(minimumCapacity: initialCapacity)
	}
	
	/// Registers an initializer for a given ServiceIdentifier
	///
	/// - Parameters:
	///   - serviceIdentifier: The ServiceIdentifier for which to register the initializer
	///   - initializer: The closure that will initialize the service when requested
	public func registerService(withIdentifier serviceIdentifier: ServiceIdentifier, initializer: @escaping ServiceInitializer) {
		factoryRegistry.registerFactory(withIdentifier: serviceIdentifier, factory: initializer)
	}
	
	/// Releases any services that are not referenced by other code
	public func releaseUnusedServices() {
		resolvedServiceReferences.removeAll() // Allows unused services to be released
		for (key, _) in resolvedServices.filter({ $1() == nil }) {
			resolvedServices.removeValue(forKey: key) // remove all keys whose value closures return nil
		}
	}
	
	/// Resolves a service by its registered ServiceIdentifier. An existing instance is returned, or created on demand via its ServiceInitializer
	///
	/// - Parameter serviceIdentifier: The ServiceIdentifier for which to resolve the service
	/// - Returns: Returns the requested service instance
	/// - Throws: Throws a CoreServiceResolvingError or Foundation error if encountered
	public func resolveService(withIdentifier serviceIdentifier: ServiceIdentifier) throws -> Any {
		var retVal = resolveServiceIfLoaded(withIdentifier: serviceIdentifier)
		if retVal == nil {
			do {
				retVal = try factoryRegistry.invokeFactory(withIdentifier: serviceIdentifier)
			} catch CoreFactoryServiceError.initializationFailure(let underlyingError) {
				throw CoreServiceProvidingError.initializationFailure(underlyingError: underlyingError)
			} catch CoreFactoryServiceError.unregisteredFactory {
				throw CoreServiceProvidingError.unregisteredService
			}
			cacheResolvedService(retVal!, using: serviceIdentifier)
		}
		// Always re-add references to the service -- it may have been previously removed by releaseUnusedServices()
		resolvedServiceReferences.insert(ResolvedServiceReference(retVal!))
		return retVal!
	}
	
	/// Resolves a service by its registered ServiceIdentifier, if and only if an instance already exists
	///
	/// - Parameter serviceIdentifier: The ServiceIdentifier for which to resolve the service
	/// - Returns: Returns an instance of the service if it is still loaded
	public func resolveServiceIfLoaded(withIdentifier serviceIdentifier: ServiceIdentifier) -> Any? {
		// TODO: Use a DispatchQueue to protect access
		guard let weakReference = resolvedServices[serviceIdentifier] else { return nil }
		return weakReference()
	}
	
	// MARK: - Private properties and methods
	
	private func cacheResolvedService(_ service: Any, using identifier: ServiceIdentifier) {
		// TODO: Use a DispatchQueue to protect access
		switch service {
		case let serviceClass as AnyObject:
			resolvedServices[identifier] = { [weak serviceClass] in serviceClass }
		default: // This effectively makes non-class-based services singletons
			resolvedServices[identifier] = { service }
		}
	}
	
	private var factoryRegistry: FactoryRegistry
	// TODO: Consider using NSCache instead of Dictionary for resolvedServices (requires the key be a class)
	private var resolvedServices: [ServiceIdentifier : () -> Any?]
	internal var resolvedServiceReferences: Set<ResolvedServiceReference> // Marked internal so that we can unit test
}
