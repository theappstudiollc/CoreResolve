//
//  CoreServiceProvidingError.swift
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

/// Error describing the reason for failures to access a service
///
/// - initializationFailure: The requested service failed to initialize because of the underlying error
/// - unmappedService: The requested service has not been mapped
public enum CoreServiceProvidingError: Error {
	
	case initializationFailure(underlyingError: Error)
	
	case unregisteredService
}

extension CoreServiceProvidingError: LocalizedError {
	
	public var errorDescription: String? {
		return NSLocalizedString("\(self).errorDescription", tableName: "CoreServiceProvidingError", bundle: Bundle(for: ServiceManager.self), comment: "\(self)")
	}
}
