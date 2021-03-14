//
//  MCSession-MultipeerSessionProviding.swift
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

import ObjectiveC
import MultipeerConnectivity

// MARK: - Provides keys for Objective C Object Association
private struct MCSessionMultipeerSessionProvidingAssociatedObjectKeys {
	static var delegate: UInt8 = 0
}

// MARK: - Adds MultipeerSessionProviding support to MCSession
extension MCSession: MultipeerSessionProviding {
	
	public func sendResource(at resourceURL: URL, withName resourceName: String, toPeer peerID: MCPeerID, withCompletionHandler completionHandler: ((MCError?) -> Void)?) -> Progress? {
		return sendResource(at: resourceURL, withName: resourceName, toPeer: peerID) { error in
			assert(error == nil || error is MCError, "\(self) reported an unexpected Error: \(error!)")
			completionHandler?(error as! MCError?)
		}
	}
	
	public weak var sessionDelegate: MultipeerSessionProvidingDelegate? {
		get {
			// Return the proxy's delegate, if it is still around
			if let proxy = delegate as! MultipeerSessionProvidingDelegateProxy?, let value = proxy.delegate {
				return value
			}
			// The proxy lost its reference to the delegate -- let's induce a clean up before returning nil
			objc_setAssociatedObject(self, &MCSessionMultipeerSessionProvidingAssociatedObjectKeys.delegate, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
			delegate = nil // The line above should allow delegate to nil out on its own eventually
			return nil
		}
		set {
			let proxy = MultipeerSessionProvidingDelegateProxy(newValue)
			objc_setAssociatedObject(self, &MCSessionMultipeerSessionProvidingAssociatedObjectKeys.delegate, proxy, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
			delegate = proxy
		}
	}
}

// MARK: - Forwards MCSessionDelegate calls to a MultipeerSessionProvidingDelegate delegate
internal final class MultipeerSessionProvidingDelegateProxy: NSObject, MCSessionDelegate {
	
	/// The delegate this proxy will forward MCSessionDelegate calls to. Keep weak references only
	internal weak var delegate: MultipeerSessionProvidingDelegate?
	
	required init?(_ delegate: MultipeerSessionProvidingDelegate?) {
		guard let delegate = delegate else { return nil }
		self.delegate = delegate
		super.init()
	}
	
	func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
		delegate?.sessionProvider(session, didFinishReceivingResourceWithName: resourceName, fromPeer: peerID, at: localURL, withError: error as! MCError?)
	}
	
	func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
		delegate?.sessionProvider(session, didReceive: data, fromPeer: peerID)
	}
	
	func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
		// Do nothing
	}
	
	func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
		// Do nothing
	}
	
	func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
		delegate?.sessionProvider(session, peer: peerID, didChange: state)
	}
}

#endif
