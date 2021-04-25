//
//  MultipeerSessionProvider.swift
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

/// Provides a lightweight MultipeerConnectivity session (i.e. a testable subset of MCSession capability)
public protocol MultipeerSessionProviding: AnyObject {
	
	/// The MultipeerSessionProvider's currently connected MCPeerIDs
	var connectedPeers: [MCPeerID] { get }
	
	/// Disconnect from the session
	func disconnect()
	
	/// The MCPeerID belonging to this MultipeerSessionProvider
	var myPeerID: MCPeerID { get }
	
	/// Sends data to a remote peer
	///
	/// - Parameters:
	///   - data: The Data to send
	///   - peerIDs: The remote MCPeerIDs to receive the data
	///   - mode: The data mode with which to send
	/// - Returns: Returns true if the send is successful (Objective C)
	/// - Throws: Throws an error if the send fails
	func send(_ data: Data, toPeers peerIDs: [MCPeerID], with mode: MCSessionSendDataMode) throws
	
	/// Sends a resource to a remote peer
	///
	/// - Parameters:
	///   - resourceURL: The file URL pointing to the resource
	///   - resourceName: A name for the resource
	///   - peerID: The remote MCPeerID to receive the resource
	///   - completionHandler: An optional completion handler that indicates success or failure
	/// - Returns: Returns a Progress object that reports the progress of the send operation
	func sendResource(at resourceURL: URL, withName resourceName: String, toPeer peerID: MCPeerID, withCompletionHandler completionHandler: ((MCError?) -> Void)?) -> Progress?
	
	/// The delegate implementing MultipeerSessionProvidingDelegate
	var sessionDelegate: MultipeerSessionProvidingDelegate? { get set }
}

#endif
