//
//  CoreFileStoreManagerUrlProviding.swift
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

/// Protocol used by CoreFileStoreManager to manage directories
public protocol CoreFileStoreManagerUrlProviding {
	
	/// Returns the URL for the given CoreFileStoreDirectoryType
	///
	/// - Parameter directoryType: The CoreFileStoreDirectoryType for which information is being requested
	/// - Returns: The URL for the given CoreFileStoreDirectoryType
	func directoryUrl(for directoryType: CoreFileStoreDirectoryType) -> URL?
	
	/// Returns whether the directory should be marked with URLResourceValues.isExcludedFromBackup
	///
	/// - Parameter directoryType: The CoreFileStoreDirectoryType for which information is being requested
	/// - Returns: Whether the directory should be marked with URLResourceValues.isExcludedFromBackup, or nil if this instance doesn't know
	func shouldExcludeForBackup(directoryType: CoreFileStoreDirectoryType) -> Bool?
}
