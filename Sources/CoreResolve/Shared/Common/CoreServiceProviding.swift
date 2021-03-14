//
//  CoreServiceProviding.swift
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
/* Stop using singletons -- See ServiceManager for a class that can support this. */

/// Provides Swift generics methods to access a service
public protocol CoreServiceProviding {
	
	/// Accesses a service that implements the requested protocol, or is the requested type
	///
	/// - Parameter serviceType: Type of the service desired. e.g. SoundEffectsService.self
	/// - Returns: Returns the concrete implementation of the requested service
	/// - Throws: Throws a CoreServiceAccessingError or implementation-specific error
	func access<T>(_ serviceType: T.Type) throws -> T where T: Any
	
	/// Accesses a service that implements the requested protocol, or is the requested type, if and only if it is still loaded in memory
	///
	/// - Parameter serviceType: Type of the service desired. e.g. SoundEffectsService.self
	/// - Returns: Returns the concrete implementation of the requested service, if it is still loaded in memory
	func accessIfLoaded<T>(_ serviceType: T.Type) -> T? where T: Any
	
	/// Releases any unused services managed by the manager of these services
	func releaseUnusedServices()
}

/// Provides Swift generics methods to configure a service
public protocol CoreServiceConfiguring {

	/// The type of Context passed into the registerService() function
	associatedtype Context: Any

	/// Registers an initializer for a given service type
	///
	/// - Parameters:
	///   - serviceType: The type of service for which to register the initializer
	///   - initializer: The closure that will initialize the service when requested
	func registerService<T>(_ serviceType: T.Type, withInitializer initializer: @escaping (_ context: Context) throws -> T)
}
