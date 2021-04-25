//
//  MultipeerMessageManagerDelegate.swift
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

/// Delegate to handle events from the MultipeerMessageManager
public protocol MultipeerMessageManagerDelegate: AnyObject {
	
	/// Notifies when the MultipeerMessageManager has received a payload from a remote peer
	///
	/// - Parameters:
	///   - messageManager: The MultipeerMessageManager instance
	///   - payload: The received MultipeerMessagePayload
	///   - peer: The remote peer that sent the MultipeerMessagePaylaod
	func messageManager(_ messageManager: MultipeerMessageManager, received payload: MultipeerMessagePayload, from peer: MCPeerID)
	
	/// Notifies when the MultipeerMessageManager's session has changed its state with a remote peer
	///
	/// - Parameters:
	///   - messageManager: The MultipeerMessageManager instance
	///   - sessionState: The new session state of the remote peer
	///   - peer: The remote peer whose session state has changed
	func messageManager(_ messageManager: MultipeerMessageManager, changed sessionState: MCSessionState, with peer: MCPeerID)
	
	/// Notifies when the MultipeerMessageManager encounters an error while decoding a message from a remote peer
	///
	/// - Parameters:
	///   - messageManager: The MultipeerMessageManager instance
	///   - error: The error encountered while decoding the MultipeerMessagePayload from the remote peer
	///   - peer: The remote peer that sent the MultipeerMessagePayload
	func messageManager(_ messageManager: MultipeerMessageManager, encountered error: Error, decodingMessageFrom peer: MCPeerID)
	
	/// Notifies when the MultipeerMessageManager encounters an error while receiving a resource from a remote peer
	///
	/// - Parameters:
	///   - messageManager: The MultipeerMessageManager instance
	///   - error: The error encountered while receiving a MultipeerMessagePayload's resource from the remote peer
	///   - identifier: The unique identifier for the specific MultipeerMessagePayload (could be used to recover and request a resend)
	///   - peer: The remote peer that sent the MultipeerMessagePayload
	func messageManager(_ messageManager: MultipeerMessageManager, encountered error: Error, receivingResource identifier: UUID, from peer: MCPeerID)
}

#endif
