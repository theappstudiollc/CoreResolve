//
//  LogManager.swift
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
import _SwiftOSOverlayShims

/// Implements the CoreLoggingService log service via a configuration
public final class LogManager {
	
	private let configurationProvider: LogManagerConfigurationProviding
	
	/// Initializes a new instance of the LogManager with a LogManagerConfigurationProviding instance
	///
	/// - Parameter configurationProvider: The LogManagerConfigurationProviding instance
	public init(configurationProvider: LogManagerConfigurationProviding) {
		self.configurationProvider = configurationProvider
	}
	
	@available(iOS 10.0, macOS 10.12.0, tvOS 10.0, watchOS 3.0, *)
	private func logAsConfigured(_ level: CoreLogLevel, _ returnAddress: UnsafeRawPointer?, dso: UnsafeRawPointer = #dsohandle, _ message: StaticString, _ args: CVaListPointer) {
		
		let osLogger = configurationProvider.logger(for: level)
		let logType = configurationProvider.logType(for: level)
		
		#if true
		// Use open-source code from Swift to allow wrapping into os_log
		guard osLogger.isEnabled(type: logType) else { return }
		
		message.withUTF8Buffer { buffer in
			// Since dladdr is in libc, it is safe to unsafeBitCast the cstring argument type.
			buffer.baseAddress!.withMemoryRebound(to: CChar.self, capacity: buffer.count) { str in
				_swift_os_log(dso, returnAddress, osLogger, logType, str, args)
			}
		}
		#else
		// TODO: We don't yet know how to convert CVaListPointer to CVarArg (kinda doesn't matter because we can't use returnAddress here)
		if #available(iOS 12.0, macOS 10.14, tvOS 12.0, watchOS 5.0, *) {
			os_log(logType, log: osLogger, message, args)
		} else {
			os_log(message, log: osLogger, type: logType, args)
		}
		#endif
	}
	
	private func logAsLegacy(_ level: CoreLogLevel, _ message: StaticString) {
		// For older OS versions, don't parse arguments because of security concerns
		print("\(level) \(message.description)")
	}
}

// MARK: - `CoreLoggingService` support
extension LogManager: CoreLoggingService {
	
	public func debug(_ message: StaticString, _ args: CVarArg...) {
		guard configurationProvider.supportedLogLevels.contains(.debug) else { return }
		guard #available(iOS 10.0, macOS 10.12.0, tvOS 10.0, watchOS 3.0, *) else {
			logAsLegacy(.debug, message)
			return
		}
		// os_log() does not support being wrapped in another function, use open-source code to add this capability
		let returnAddress = _swift_os_log_return_address()
		withVaList(args) { argList in
			logAsConfigured(.debug, returnAddress, message, argList)
		}
	}
	
	public func log(_ level: CoreLogLevel, _ message: StaticString, _ args: CVarArg...) {
		guard configurationProvider.supportedLogLevels.contains(level) else { return }
		guard #available(iOS 10.0, macOS 10.12.0, tvOS 10.0, watchOS 3.0, *) else {
			logAsLegacy(.debug, message)
			return
		}
		// os_log() does not support being wrapped in another function, use open-source code to add this capability
		let returnAddress = _swift_os_log_return_address()
		withVaList(args) { argList in
			logAsConfigured(level, returnAddress, message, argList)
		}
	}
}
