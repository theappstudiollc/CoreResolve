//
//  CoreLoggingService.swift
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

import Foundation

/// Represents logging levels for use with a `CoreLoggingService`
///
/// - `default`: Use this level to capture information about things that might result in a failure
/// - debug: Messages logged at this level contain information that may be useful during development or while troubleshooting a specific problem. Debug logging is intended for use in a development environment and not in shipping software
/// - info: Use this level to capture information that may be helpful, but isn’t essential, for troubleshooting errors
/// - error: Error-level messages are intended for reporting process-level errors
/// - fault: Fault-level messages are intended for capturing system-level or multi-process errors only
/// - applicationReserved0: An application reserved value for a log level
/// - applicationReserved1: An application reserved value for a log level
/// - applicationReserved2: An application reserved value for a log level
/// - applicationReserved3: An application reserved value for a log level
public enum CoreLogLevel: Int {
	case `default`
	case debug
	case info
	case error
	case fault
	case applicationReserved0 = 128
	case applicationReserved1
	case applicationReserved2
	case applicationReserved3
}

/// Represents a service that provides logging capabilities for Apple Operating Systems that don't have the `Logger` struct (e.g. before iOS 14, macOS 11, tvOS 14, and watchOS 7)
public protocol CoreLoggingService {

	/// Logs a message using the `debug` log level
	///
	/// - Parameters:
	///   - message: The message to log
	///   - args: The arguments to the message
	func debug(_ message: StaticString, _ args: CVarArg...)
	
	/// Logs a message
	///
	/// - Parameters:
	///   - level: The `CoreLogLevel` to log at
	///   - message: The message to log
	///   - args: The arguments to the message
	func log(_ level: CoreLogLevel, _ message: StaticString, _ args: CVarArg...)
}
