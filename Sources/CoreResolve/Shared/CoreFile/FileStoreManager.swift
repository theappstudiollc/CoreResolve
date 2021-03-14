//
//  FileStoreManager.swift
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

/// Manages directories identified via the CoreFileStoreDirectoryType enum
public final class FileStoreManager: CoreFileStoreService {
	
	/// Returns the file URL for the provided directoryType
	///
	/// - Parameter directoryType: The requested CoreFileStoreDirectoryType
	/// - Returns: The file URL for the provided directoryType
	/// - Throws: Throws a CoreFileStoreServiceError
	public func directoryUrl(for directoryType: CoreFileStoreDirectoryType) throws -> URL {
		guard let retVal = urlProvider.directoryUrl(for: directoryType) else {
			throw CoreFileStoreServiceError.unknownDirectoryType
		}
		return retVal
	}
	
	/// Ensures the directory for the provided directoryType exists on the file system
	///
	/// - Parameter directoryType: The CoreFileStoreDirectoryType
	/// - Throws: Throws a CoreFileStoreServiceError or Foundation error
	public func ensureDirectoryExists(for directoryType: CoreFileStoreDirectoryType) throws {
		try ensureDirectoryExists(for: directoryType, withSubpath: nil)
	}
	
	/// Ensures the directory for the provided directoryType exists on the file system, also including an optional subpath
	///
	/// - Parameters:
	///   - directoryType: The CoreFileStoreDirectoryType
	///   - subpath: An optional subpath to append to the directory URL
	/// - Throws: Throws a CoreFileStoreServiceError or Foundation error
	public func ensureDirectoryExists(for directoryType: CoreFileStoreDirectoryType, withSubpath subpath: String? = nil) throws {
		switch directoryType {
		case .documents:
			return // This directory is already created by the OS
		default:
			var directoryUrl = try self.directoryUrl(for: directoryType)
			if let subpath = subpath, subpath.count > 0 {
				directoryUrl = directoryUrl.appendingPathComponent(subpath, isDirectory: true)
			}
			let fileCoordinator = NSFileCoordinator(filePresenter: nil)
			try fileCoordinator.coordinateWrite(at: directoryUrl, options: .forDeleting) { writingURL in
				let exists = (try? writingURL.checkResourceIsReachable()) ?? false
				if !exists {
					try fileManager.createDirectory(at: writingURL, withIntermediateDirectories: true, attributes: nil)
				}
				if let exclude = urlProvider.shouldExcludeForBackup(directoryType: directoryType) {
					var resourceValues = URLResourceValues()
					resourceValues.isExcludedFromBackup = exclude
					try directoryUrl.setResourceValues(resourceValues)
				}
			}
		}
	}
	
	/// Initializes a new instance of the CoreFileStoreManager with a CoreFileStoreManagerUrlProviding instance
	///
	/// - Parameter fileManager: The desired FileManager instance to use when creating directories
	/// - Parameter urlProvider: The CoreFileStoreManagerUrlProviding instance
	required public init(fileManager: FileManager = .default, urlProvider: CoreFileStoreManagerUrlProviding = CoreFileStoreManagerUrlProvider()) {
		self.fileManager = fileManager
		self.urlProvider = urlProvider
	}
	
	let fileManager: FileManager
	let urlProvider: CoreFileStoreManagerUrlProviding
}
