//
//  CoreFactoryService.swift
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

/// Provides Swift generics methods to invoke a factory
public protocol CoreFactoryService {
	
	/// Makes the requested object type
	///
	/// - Parameter objectType: Type of the object desired. e.g. MainViewModel.self
	/// - Returns: Returns the requested object type
	/// - Throws: Throws a CoreFactoryServiceError or implementation-specific error
	func make<T>(_ objectType: T.Type) throws -> T
}

/// Provides Swift generics methods to configure a factory
public protocol CoreFactoryConfiguring {

	/// The type of Context passed into the registerFactory() function
	associatedtype Context: Any
	
	/// Registers a factory for a given object type
	///
	/// - Parameters:
	///   - objectType: The type of object for which to register the factory
	///   - builder: The closure that will manufacture objects when invoked
	func registerFactory<T: Any>(_ objectType: T.Type, withBuilder builder: @escaping (_ context: Context) throws -> T)
}
