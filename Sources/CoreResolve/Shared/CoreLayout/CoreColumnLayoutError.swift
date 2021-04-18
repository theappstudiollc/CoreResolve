//
//  CoreColumnLayoutError.swift
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
#if os(iOS) || os(tvOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

/// Error describing the reason for failures to layout a column
///
/// - columnLayoutProvidingNotAvailable: The ColumnLayoutProviding instance is not (yet) available
/// - invalidColumnSpecified: The specified column index does not exist for the `CoreColumnLayoutProviding` instance. The invalid column and maxAllowed values are provided
public enum CoreColumnLayoutError: Error {

	case columnLayoutProvidingNotAvailable

	case invalidColumnSpecified(_ column: Int, maxAllowed: Int)
}

extension CoreColumnLayoutError: LocalizedError {

	public var errorDescription: String? {
		return NSLocalizedString("\(self).errorDescription", tableName: "CoreColumnLayoutError", bundle: Bundle(for: CoreColumnLayoutProvider.self), comment: "\(self)")
	}
}

#endif
