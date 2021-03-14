//
//  MultipeerSessionManagerDelegate.swift
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

internal protocol MultipeerSessionManagerDelegate: class {
	
	func copyResource(with name: String, at url: URL) throws -> URL
	
	func notify(changed state: MCSessionState, with peerID: MCPeerID)
	
	func notify(error: Error, decodingMessageFrom peerID: MCPeerID)
	
	func notify(error: Error, receivingResource uuid: UUID, from peerID: MCPeerID)
	
	func notify(received payload: MultipeerMessagePayload, from peerID: MCPeerID)
}

#endif
