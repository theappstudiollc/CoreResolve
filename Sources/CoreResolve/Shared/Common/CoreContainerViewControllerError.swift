//
//  CoreContainerViewControllerError.swift
//  CoreResolve
//
//  Created by David Mitchell
//  Copyright © 2021 The App Studio LLC.
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

import Foundation

/// Error describing the reason for failures using `CoreContainerViewController`
///
/// - unsupportedState: Cannot use `Animation.assignOnly` when an `activeChild` already exists
public enum CoreContainerViewControllerError: Error {

	case unsupportedState
}

extension CoreContainerViewControllerError: LocalizedError {

	public var errorDescription: String? {
		return NSLocalizedString("\(self).errorDescription", tableName: "CoreContainerViewControllerError", bundle: Bundle(for: CoreContainerViewController.self), comment: "\(self)")
	}
}

#endif
