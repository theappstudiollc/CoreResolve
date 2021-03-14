//
//  CoreFileStoreManagerUrlProvider.swift
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

/// Implements the basic CoreFileStoreManagerUrlProviding capability (minus ApplicationReserved directories)
open class CoreFileStoreManagerUrlProvider: CoreFileStoreManagerUrlProviding {
	
	/// Returns the URL for the given CoreFileStoreDirectoryType
	///
	/// - Parameter directoryType: The CoreFileStoreDirectoryType for which information is being requested
	/// - Returns: The URL for the given CoreFileStoreDirectoryType, or nil if unknown
	open func directoryUrl(for directoryType: CoreFileStoreDirectoryType) -> URL? {
		switch directoryType {
		case .applicationSupport:
			if let applicationSupportDirectoryURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
				return applicationSupportDirectoryURL.appendingPathComponent(applicationBundleString, isDirectory: true)
			}
		case .cache:
			if let cacheDirectoryURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first {
				return cacheDirectoryURL.appendingPathComponent(applicationBundleString, isDirectory: true)
			}
		case .desktop:
			return fileManager.urls(for: .desktopDirectory, in: .userDomainMask).first
		case .documents:
			return fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
		case .library:
			return fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first
		default:
			return nil
		}
		return nil
	}
	
	/// Returns whether the directory should be marked with URLResourceValues.isExcludedFromBackup
	///
	/// - Parameter directoryType: The CoreFileStoreDirectoryType for which information is being requested
	/// - Returns: Whether the directory should be marked with URLResourceValues.isExcludedFromBackup, or nil if this instance doesn't know
	open func shouldExcludeForBackup(directoryType: CoreFileStoreDirectoryType) -> Bool? {
		switch directoryType {
		case .applicationSupport, .cache: return true
		default: return nil
		}
	}
	
	/// Initializes a new instance of the CoreFileStoreManagerUrlProvider
	///
	/// - Parameter applicationBundle: The Bundle for the Application so that proper URLs can be calculated
	public init(applicationBundle: Bundle = Bundle(for: CoreFileStoreManagerUrlProvider.self), fileManager: FileManager = .default) {
		// TODO: We need to either make this init throw or pass in something different in the parameter
		self.applicationBundleString = applicationBundle.bundleIdentifier ?? ""
		self.fileManager = fileManager
	}
	
	let applicationBundleString: String
	let fileManager: FileManager
}
