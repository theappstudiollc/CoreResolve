//
//  LogManagerConfigurationProviding.swift
//  CoreResolve
//
//  Created by David Mitchell
//  Copyright © 2019 The App Studio LLC.
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

import os.log

/// Protocol used by a LogManager instance to configure log message routing via os.log
public protocol LogManagerConfigurationProviding {
	
	/// The supported log levels for this configuration provider
	var supportedLogLevels: [CoreLogLevel] { get }
	
	/// Returns the `OSLog` instance that will route for the provided log level
	///
	/// - Parameter logLevel: The `CoreLogLevel` for which an `OSLog` instance is requested
	/// - Returns: Returns the `OSLog` instance for the provided log level
	@available(iOS 10.0, macOS 10.12.0, tvOS 10.0, watchOS 3.0, *)
	func logger(for logLevel: CoreLogLevel) -> OSLog
	
	/// Returns the `OSLogType` that maps to the specified `CoreLogLevel`
	///
	/// - Parameter logLevel: The `CoreLogLevel` to convert to an `OSLogType`
	/// - Returns: Returns the `OSLogType` for the provided log level
	@available(iOS 10.0, macOS 10.12.0, tvOS 10.0, watchOS 3.0, *)
	func logType(for logLevel: CoreLogLevel) -> OSLogType
}
