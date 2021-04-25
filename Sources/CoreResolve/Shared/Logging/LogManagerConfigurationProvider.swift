//
//  LogManagerConfigurationProvider.swift
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
import Foundation

/// Implements the basic LogManagerConfigurationProviding capability (minus ApplicationReserved log levels)
public struct LogManagerConfigurationProvider: LogManagerConfigurationProviding {
	
	internal let category: String?
	private let osLogger: OSLog!
	
	public let supportedLogLevels: [CoreLogLevel] = [.`default`, .debug, .info, .error, .fault]
	
	@available(iOS 10.0, tvOS 10.0, watchOS 3.0, *)
	public init(osLog: OSLog) {
		category = nil
		osLogger = osLog
	}
	
	public init() {
		category = nil
		if #available(iOS 10.0, macOS 10.12.0, tvOS 10.0, watchOS 3.0, *) {
			osLogger = .default
		} else {
			osLogger = nil
		}
	}

	public init(bundle: Bundle, category: String = "\(CoreLoggingService.self)") {
		self.category = category
		if #available(iOS 10.0, macOS 10.12.0, tvOS 10.0, watchOS 3.0, *) {
			if let bundleIdentifier = bundle.bundleIdentifier {
				osLogger = OSLog(subsystem: bundleIdentifier, category: category)
			} else {
				osLogger = .default
			}
		} else {
			osLogger = nil
		}
	}
	
	@available(iOS 10.0, tvOS 10.0, watchOS 3.0, *)
	public func logger(for logLevel: CoreLogLevel) -> OSLog {
		return osLogger
	}
	
	@available(iOS 10.0, macOS 10.12.0, tvOS 10.0, watchOS 3.0, *)
	public func logType(for logLevel: CoreLogLevel) -> OSLogType {
		switch logLevel {
		case .debug: return .debug
		case .default: return .default
		case .error: return .error
		case .fault: return .fault
		case .info: return .info
		default: return .default
		}
	}
}
