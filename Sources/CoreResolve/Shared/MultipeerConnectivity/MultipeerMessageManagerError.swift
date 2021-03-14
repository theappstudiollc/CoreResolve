//
//  MultipeerMessageManagerError.swift
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

#if canImport(MultipeerConnectivity)

import MultipeerConnectivity
import Foundation

/// Error describing the reason for failures to send or receive a message
///
/// - missingResourceContainer: No resourceContainer URL has been set to receive a MultipeerMessagePayload containing a resource
/// - noActiveSession: No MultipeerSessionProviding instance has been provided to the MultipeerMessageManager when sending a MultipeerMessagePayload
/// - noConnectedPeers: No MCPeerIDs are connected whom to send the MultipeerMessagePayload
/// - partialErrors: One or more Errors were encountered while sending to MCPeerIDs. A Dictionary is provided for you to handle them if desired
/// - unexpectedError: An invalid condition was encountered, but no error was provided by the underlying framework
public enum MultipeerMessageManagerError: Error {
	
	case missingResourceContainer
	
	case noActiveSession
	
	case noConnectedPeers
	
	case partialErrors(errors: [MCPeerID : MCError])
	
	case unexpectedError
}

extension MultipeerMessageManagerError: LocalizedError {
	
	public var errorDescription: String? {
		return NSLocalizedString("\(self).errorDescription", tableName: "MultipeerMessageManagerError", bundle: Bundle(for: MultipeerMessageManager.self), comment: "\(self)")
	}
}

#endif
