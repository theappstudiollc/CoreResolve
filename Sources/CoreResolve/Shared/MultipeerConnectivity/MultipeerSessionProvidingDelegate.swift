//
//  MultipeerSessionProvidingDelegate.swift
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

/// Handles events from the MultipeerSessionProviding instance
public protocol MultipeerSessionProvidingDelegate: class {
	
	/// Finished receiving a resource from a remote peer
	///
	/// - Parameters:
	///   - sessionProvider: The MultipeerSessionProviding instance
	///   - resourceName: The name of the resource
	///   - peerID: The remote MCPeerID that sent the resource
	///   - localURL: The local URL temporarily housing the resource, if the operation is successful. The delegate must move the resource to a permanent location before exiting
	///   - error: The error encountered while receiving the resource, if the operation failed. The resourceName can help clients recover
	func sessionProvider(_ sessionProvider: MultipeerSessionProviding, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: MCError?)
	
	/// Finished receiving Data from a remote peer
	///
	/// - Parameters:
	///   - sessionProvider: The MultipeerSessionProviding instance
	///   - data: The received Data
	///   - peerID: The remote MCPeerID that sent the data
	func sessionProvider(_ sessionProvider: MultipeerSessionProviding, didReceive data: Data, fromPeer peerID: MCPeerID)
	
	/// Received a certificate during a new connection to a remote peer
	///
	/// - Parameters:
	///   - sessionProvider: The MultipeerSessionProviding instance
	///   - certificate: The certificate object
	///   - peerID: The remote MCPeerID for the certificate
	///   - certificateHandler: A handler that needs to be called to inform whether to accept or deny the attempt to connect
	func sessionProvider(_ sessionProvider: MultipeerSessionProviding, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void)
	
	/// Session state changed for a remote peer
	///
	/// - Parameters:
	///   - sessionProvider: The MultipeerSessionProviding instance
	///   - peerID: The remote MCPeerID whose session state has changed
	///   - state: The session connection state
	func sessionProvider(_ sessionProvider: MultipeerSessionProviding, peer peerID: MCPeerID, didChange state: MCSessionState)
}

#endif
