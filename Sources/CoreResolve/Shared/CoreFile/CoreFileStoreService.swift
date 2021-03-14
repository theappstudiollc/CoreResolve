//
//  CoreFileStoreService.swift
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

/// Directories supported by CoreFileStoreService. Applications can extend via the applicationReserved constants (for example, for iCloud Drive)
///
/// - applicationSupport: The user Application Support directory. Not available on tvOS
/// - cache: The user Cache directory
/// - desktop: The macOS user Desktop. Use only if your app is not sandboxed
/// - documents: The user Documents directory
/// - library: The user Library directory. For user-specific files that are not visible to the user
/// - applicationReserved0: An application reserved value for a directory
/// - applicationReserved1: An application reserved value for a directory
/// - applicationReserved2: An application reserved value for a directory
/// - applicationReserved3: An application reserved value for a directory
/// - applicationReserved4: An application reserved value for a directory
/// - applicationReserved5: An application reserved value for a directory
/// - applicationReserved6: An application reserved value for a directory
/// - applicationReserved7: An application reserved value for a directory
public enum CoreFileStoreDirectoryType: Int {
	case applicationSupport = 0
	case cache
	case desktop
	case documents
	case library
	case applicationReserved0 = 128
	case applicationReserved1
	case applicationReserved2
	case applicationReserved3
	case applicationReserved4
	case applicationReserved5
	case applicationReserved6
	case applicationReserved7
}

/// Manages directories identified via the CoreFileStoreDirectoryType enum
public protocol CoreFileStoreService {

	/// Returns the file URL for the provided directoryType
	///
	/// - Parameter directoryType: The requested CoreFileStoreDirectoryType
	/// - Returns: The file URL for the provided directoryType
	/// - Throws: Throws a CoreFileStoreServiceError or implementation-specific error
	func directoryUrl(for directoryType: CoreFileStoreDirectoryType) throws -> URL
	
	/// Ensures the directory for the provided directoryType exists on the file system
	///
	/// - Parameter directoryType: The CoreFileStoreDirectoryType
	/// - Throws: Throws a CoreFileStoreServiceError or implementation-specific error
	func ensureDirectoryExists(for directoryType: CoreFileStoreDirectoryType) throws
	
	/// Ensures the directory for the provided directoryType exists on the file system, also including an optional subpath
	///
	/// - Parameters:
	///   - directoryType: The CoreFileStoreDirectoryType
	///   - subpath: An optional subpath to append to the directory URL
	/// - Throws: Throws a CoreFileStoreServiceError or implementation-specific error
	func ensureDirectoryExists(for directoryType: CoreFileStoreDirectoryType, withSubpath subpath: String?) throws
}
