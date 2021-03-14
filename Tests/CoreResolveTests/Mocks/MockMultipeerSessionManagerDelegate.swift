//
//  MockMultipeerSessionManagerDelegate.swift
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
@testable import CoreResolve

class MockMultipeerSessionManagerDelegate {
	
	public var copyResourceHandler: ((_: String, _: URL) throws -> URL)?
	
	public var notifyChangedStateHandler: ((_: MCSessionState, _: MCPeerID) -> Void)?
	
	public var notifyErrorDecodingMessageHandler: ((_: Error, _: MCPeerID) -> Void)?
	
	public var notifyErrorReceivingResourceHandler: ((_: Error, _: UUID, _: MCPeerID) -> Void)?
	
	public var notifyReceivedPayloadHandler: ((_: MultipeerMessagePayload, _: MCPeerID) -> Void)?
}

extension MockMultipeerSessionManagerDelegate: MultipeerSessionManagerDelegate {
	
	func copyResource(with name: String, at url: URL) throws -> URL {
		if let handler = copyResourceHandler {
			return try handler(name, url)
		}
		return url
	}
	
	func notify(changed state: MCSessionState, with peerID: MCPeerID) {
		notifyChangedStateHandler?(state, peerID)
	}
	
	func notify(error: Error, decodingMessageFrom peerID: MCPeerID) {
		notifyErrorDecodingMessageHandler?(error, peerID)
	}
	
	func notify(error: Error, receivingResource uuid: UUID, from peerID: MCPeerID) {
		notifyErrorReceivingResourceHandler?(error, uuid, peerID)
	}
	
	func notify(received payload: MultipeerMessagePayload, from peerID: MCPeerID) {
		notifyReceivedPayloadHandler?(payload, peerID)
	}
}

#endif
