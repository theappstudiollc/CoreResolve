//
//  MultipeerSessionManager.swift
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

/// Handles MultipeerSessionProviding interaction for the MultipeerMessageManager
internal class MultipeerSessionManager {
	
	/// The delegate that will handle events from the MultipeerSessionManager
	public weak var delegate: MultipeerSessionManagerDelegate?
	
	/// The MultipeerSessionProviding instance (e.g. MCSession) to manage
	public let sessionProvider: MultipeerSessionProviding
	
	deinit {
		self.delegate = nil
		self.sessionProvider.sessionDelegate = nil
		self.sessionProvider.disconnect()
	}
	
	/// Initializes a new instance of the MultipeerSessionManager
	///
	/// - Parameters:
	///   - messageDecoder: The CoreDecoding instance that will decode messages
	///   - messageEncoder: The CoreEncoding instance that will encode messages
	///   - sessionProvider: The MultipeerSessionProviding instance to manage
	///   - delegate: The delegate that will handle events for this MultipeerSessionManager
	required public init(messageDecoder: CoreDecoding = JSONDecoder(), messageEncoder: CoreEncoding = JSONEncoder(), sessionProvider: MultipeerSessionProviding, delegate: MultipeerSessionManagerDelegate) {
		self.messageDecoder = messageDecoder
		self.messageEncoder = messageEncoder
		self.sessionProvider = sessionProvider
		self.delegate = delegate
		self.sessionProvider.sessionDelegate = self
	}
	
	/// Sends a MultipeerMessagePayload to remote peers
	///
	/// - Parameters:
	///   - message: The MultipeerMessagePayload to send
	///   - peers: The peers that should receive the message
	///   - completion: A completion handler that indicates success or failure
	/// - Returns: A Progress object that reports the progress of sending a resource, if included in the MultipeerMessagePayload
	@discardableResult public func send(_ message: MultipeerMessagePayload, to peers: [MCPeerID]? = nil, completion: @escaping (Error?) -> Void) -> Progress? {
		do {
			let recipients = peers ?? sessionProvider.connectedPeers
			let data = try messageEncoder.encode(message)
			try sessionProvider.send(data, toPeers: recipients, with: .reliable)
			guard let resourceURL = message.resourceURL else {
				completion(nil)
				return nil
			}
			let resourceName = "\(message.uuid.uuidString)/\(resourceURL.lastPathComponent)"
			let resourceGroup = DispatchGroup()
			var partialErrors = [MCPeerID : MCError]()
			let progress = Progress(totalUnitCount: Int64(recipients.count))
			for recipient in recipients {
				resourceGroup.enter()
				if let childProgress = sessionProvider.sendResource(at: resourceURL, withName: resourceName, toPeer: recipient, withCompletionHandler: { error in
					self.syncQueue.sync {
						partialErrors[recipient] = error
					}
					resourceGroup.leave()
				}) {
					progress.addChild(childProgress, withPendingUnitCount: 1)
				} else {
					progress.totalUnitCount -= 1
				}
			}
			DispatchQueue.global().async {
				resourceGroup.wait()
				let error = self.syncQueue.sync {
					return partialErrors.count > 0 ? MultipeerMessageManagerError.partialErrors(errors: partialErrors) : nil
				}
				completion(error)
			}
			return progress
		} catch {
			completion(error)
			return nil
		}
	}
	
	let messageDecoder: CoreDecoding
	let messageEncoder: CoreEncoding
	var pendingResourceURLs = [UUID : URL]()
	var pendingMessagePayloads = [UUID : MultipeerMessagePayload]()
	let syncQueue = DispatchQueue(label: "\(MultipeerSessionManager.self).queue")
	
	func removePayload(forKey uuid: UUID) -> MultipeerMessagePayload? {
		return syncQueue.sync {
			return pendingMessagePayloads.removeValue(forKey: uuid)
		}
	}
	
	func removeResourceURL(forKey uuid: UUID) -> URL? {
		return syncQueue.sync {
			return pendingResourceURLs.removeValue(forKey: uuid)
		}
	}
	
	func store(_ payload: MultipeerMessagePayload) {
		syncQueue.sync {
			pendingMessagePayloads[payload.uuid] = payload
		}
	}
	
	func store(_ resourceURL: URL, for uuid: UUID) {
		syncQueue.sync {
			pendingResourceURLs[uuid] = resourceURL
		}
	}
}

#endif
