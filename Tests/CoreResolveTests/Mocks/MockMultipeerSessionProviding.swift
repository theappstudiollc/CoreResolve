//
//  MockMultipeerSessionProviding.swift
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

import CoreResolve
import MultipeerConnectivity

public class MockMultipeerSessionProviding {
	
	public var connectedPeers: [MCPeerID]
	
	public var myPeerID: MCPeerID
	
	public weak var sessionDelegate: MultipeerSessionProvidingDelegate? {
		didSet { sessionDelegateDidSetHandler?(sessionDelegate) }
	}
	
	public init(myPeerName: String, with connectedPeerNames: [String]) {
		myPeerID = MCPeerID(displayName: myPeerName)
		connectedPeers = connectedPeerNames.map { MCPeerID(displayName: $0) }
	}
	
	public var disconnectHandler: (() -> Void)?
	
	public var sendHandler: ((_: MultipeerSessionProviding, _: Data, _: [MCPeerID], _: MCSessionSendDataMode) throws -> Void)? = { provider, data, peerIDs, mode in
		guard peerIDs.count > 0 else {
			throw MCError(.unsupported)
		}
		provider.sessionDelegate?.sessionProvider(provider, didReceive: data, fromPeer: provider.myPeerID)
	}
	
	public var sendResourceHandler: ((_: MultipeerSessionProviding, _: URL, _: String, _: MCPeerID, _: ((MCError?) -> Void)?) -> Progress?)? = { provider, url, resourceName, peerID, completion in
		provider.sessionDelegate?.sessionProvider(provider, didFinishReceivingResourceWithName: resourceName, fromPeer: provider.myPeerID, at: url, withError: nil)
		completion?(nil)
		return Progress(totalUnitCount: 1)
	}
	
	public var sessionDelegateDidSetHandler: ((MultipeerSessionProvidingDelegate?) -> Void)?
}

extension MockMultipeerSessionProviding: MultipeerSessionProviding {
	
	public func disconnect() {
		disconnectHandler?()
	}
	
	public func send(_ data: Data, toPeers peerIDs: [MCPeerID], with mode: MCSessionSendDataMode) throws {
		try sendHandler?(self, data, peerIDs, mode)
	}
	
	public func sendResource(at resourceURL: URL, withName resourceName: String, toPeer peerID: MCPeerID, withCompletionHandler completionHandler: ((MCError?) -> Void)?) -> Progress? {
		return sendResourceHandler?(self, resourceURL, resourceName, peerID, completionHandler)
	}
}

#endif
