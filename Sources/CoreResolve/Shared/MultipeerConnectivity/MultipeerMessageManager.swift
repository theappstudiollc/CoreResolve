//
//  MultipeerMessageManager.swift
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

import Foundation
import MultipeerConnectivity

/// Manages communications between multiple peers
public final class MultipeerMessageManager {
	
	/// The DispatchQueue for all completion handlers and delegate methods. Defaults to the Main queue if none is specified
	public var callbackQueue: DispatchQueue?
	
	/// The delegate to handle events from the MultipeerMessageManager
	public weak var delegate: MultipeerMessageManagerDelegate?
	
	/// The file directory URL that will contain resources included in received MultipeerMessagePayloads
	public var resourceContainer: URL?
	
	/// The MultipeerSessionProviding instance (e.g. MCSession) that this manager will manage
	public var sessionProvider: MultipeerSessionProviding? {
		get {
			return sessionManager?.sessionProvider
		}
		set {
			if let session = newValue {
				sessionManager = MultipeerSessionManager(sessionProvider: session, delegate: self)
			} else {
				sessionManager = nil
			}
		}
	}
	
	/// Initializes a new instance of the MultipeerMessageManager
	///
	/// - Parameters:
	///   - sessionProvider: The MultipeerSessionProviding instance
	///   - resourceContainer: The optional file directory URL that contains incoming resources
	public init(with sessionProvider: MultipeerSessionProviding?, fileManager: FileManager = .default, resourceContainer: URL?) {
		self.fileManager = fileManager
		self.sessionProvider = sessionProvider
		self.resourceContainer = resourceContainer
	}
	
	/// Sends a MultipeerMessagePayload to the specified peers
	///
	/// - Parameters:
	///   - message: The MultipeerMessagePayload to send
	///   - peers: The peers that should receive the message
	///   - completion: A completion handler that indicates success or failure
	/// - Returns: A Progress object that reports the progress of the send operation
	@discardableResult public func send(_ message: MultipeerMessagePayload, to peers: [MCPeerID]? = nil, completion: @escaping (Error?) -> Void) -> Progress? {
		guard let sessionManager = sessionManager else {
			(callbackQueue ?? .main).async { completion(MultipeerMessageManagerError.noActiveSession) }
			return nil
		}
		guard sessionManager.sessionProvider.connectedPeers.count > 0 else {
			(callbackQueue ?? .main).async { completion(MultipeerMessageManagerError.noConnectedPeers) }
			return nil
		}
		return sessionManager.send(message, to: peers) { error in
			(self.callbackQueue ?? .main).async { completion(error) }
		}
	}
	
	// MARK: - Private properties and methods
	
	var fileManager: FileManager
	var sessionManager: MultipeerSessionManager?
}

extension MultipeerMessageManager: MultipeerSessionManagerDelegate {
	
	func copyResource(with name: String, at url: URL) throws -> URL {
		guard let resourceContainer = resourceContainer else {
			throw MultipeerMessageManagerError.missingResourceContainer
		}
		let resourceURL = URL(fileURLWithPath: name, relativeTo: resourceContainer)
		try fileManager.moveFileCreatingDirectories(from: url, to: resourceURL)
		return resourceURL
	}
	
	func notify(changed state: MCSessionState, with peerID: MCPeerID) {
		(callbackQueue ?? .main).sync {
			delegate?.messageManager(self, changed: state, with: peerID)
		}
	}
	
	func notify(error: Error, decodingMessageFrom peerID: MCPeerID) {
		(callbackQueue ?? .main).sync {
			delegate?.messageManager(self, encountered: error, decodingMessageFrom: peerID)
		}
	}
	
	func notify(error: Error, receivingResource uuid: UUID, from peerID: MCPeerID) {
		(callbackQueue ?? .main).sync {
			delegate?.messageManager(self, encountered: error, receivingResource: uuid, from: peerID)
		}
	}
	
	func notify(received payload: MultipeerMessagePayload, from peerID: MCPeerID) {
		(callbackQueue ?? .main).sync {
			delegate?.messageManager(self, received: payload, from: peerID)
		}
	}
}

#endif
