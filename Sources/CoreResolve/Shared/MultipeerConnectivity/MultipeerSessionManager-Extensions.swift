//
//  MultipeerSessionManager-Extensions.swift
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

extension MultipeerSessionManager: MultipeerSessionProvidingDelegate {
	
	public func sessionProvider(_ sessionProvider: MultipeerSessionProviding, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: MCError?) {
		guard let uuidString = resourceName.components(separatedBy: "/").first, let uuid = UUID(uuidString: uuidString) else {
			return // It's possible this resource came from something else? Either way, don't bring down the app
		}
		let payload = removePayload(forKey: uuid) // Error or not, we're removing the associated payload
		guard error == nil, let localURL = localURL else {
			delegate?.notify(error: error ?? MultipeerMessageManagerError.unexpectedError, receivingResource: uuid, from: peerID)
			return
		}
		do {
			if let resourceURL = try delegate?.copyResource(with: resourceName, at: localURL) {
				if var payload = payload {
					payload.resourceURL = resourceURL
					delegate?.notify(received: payload, from: peerID)
				} else {
					store(resourceURL, for: uuid)
				}
			}
		} catch {
			delegate?.notify(error: error, receivingResource: uuid, from: peerID)
		}
	}
	
	public func sessionProvider(_ sessionProvider: MultipeerSessionProviding, didReceive data: Data, fromPeer peerID: MCPeerID) {
		do {
			var payload = try messageDecoder.decode(MultipeerMessagePayload.self, from: data)
			if payload.resourceURL == nil {
				delegate?.notify(received: payload, from: peerID)
			} else if let pendingResource = removeResourceURL(forKey: payload.uuid) {
				payload.resourceURL = pendingResource
				delegate?.notify(received: payload, from: peerID)
			} else {
				store(payload)
			}
		} catch {
			delegate?.notify(error: error, decodingMessageFrom: peerID)
		}
	}
	
	public func sessionProvider(_ sessionProvider: MultipeerSessionProviding, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
		certificateHandler(true)
	}
	
	public func sessionProvider(_ sessionProvider: MultipeerSessionProviding, peer peerID: MCPeerID, didChange state: MCSessionState) {
		delegate?.notify(changed: state, with: peerID)
	}
}

#endif
