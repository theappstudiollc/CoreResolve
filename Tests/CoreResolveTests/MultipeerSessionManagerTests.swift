//
//  MultipeerSessionManagerTests.swift
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

#if !os(watchOS) && canImport(MultipeerConnectivity)

import XCTest
import MultipeerConnectivity
@testable import CoreResolve

final class MultipeerSessionManagerTests: XCTestCase {
	
	func testCorrectSetup() {
		let certificateAccepted = expectation(description: "Certificate handled")
		let delegateAssigned = expectation(description: "Session delegate assigned")
		let stateChangeNotified = expectation(description: "State change notified")
		
		let mockProvider = MockMultipeerSessionProviding(myPeerName: "ME", with: ["PEER"])
		let mockDelegate = MockMultipeerSessionManagerDelegate()
		
		mockProvider.sessionDelegateDidSetHandler = { value in
			if value != nil {
				delegateAssigned.fulfill()
				value?.sessionProvider(mockProvider, peer: mockProvider.connectedPeers.first!, didChange: .connected)
			}
		}
		mockDelegate.notifyChangedStateHandler = { state, peerID in
			XCTAssertEqual(state, .connected)
			XCTAssertEqual(peerID, mockProvider.connectedPeers.first)
			stateChangeNotified.fulfill()
		}
		
		let subject = MultipeerSessionManager(sessionProvider: mockProvider, delegate: mockDelegate)
		XCTAssert(subject.delegate === mockDelegate)
		subject.sessionProvider(mockProvider, didReceiveCertificate: nil, fromPeer: mockProvider.connectedPeers.first!) { shouldConnect in
			XCTAssertTrue(shouldConnect)
			certificateAccepted.fulfill()
		}
		waitForExpectations(timeout: 5.0, handler: nil)
	}
	
	func testCorrectTeardown() {
		// We expect the subject's deinit to be called, and that mockProvider's disconnect() will be called
		let disconnectCalled = expectation(description: "Session's disconnect() called")
		
		let mockProvider = MockMultipeerSessionProviding(myPeerName: "ME", with: ["PEER"])
		let mockDelegate = MockMultipeerSessionManagerDelegate()
		
		mockProvider.disconnectHandler = {
			disconnectCalled.fulfill()
		}
		
		var subject: MultipeerSessionManager? = MultipeerSessionManager(sessionProvider: mockProvider, delegate: mockDelegate)
		XCTAssertNotNil(subject)
		subject = nil // We expect disconnect to be called, and that the sessionDelegate will be nil'ed out
		XCTAssertNil(mockProvider.sessionDelegate)
		waitForExpectations(timeout: 5.0, handler: nil)
	}
	
	func testMessageSendSuccessful() {
		let sentWithoutFailure = expectation(description: "Sending a message")
		
		let mockProvider = MockMultipeerSessionProviding(myPeerName: "ME", with: ["PEER"])
		let mockDelegate = MockMultipeerSessionManagerDelegate()
		let payload = MultipeerMessagePayload(text: "test")
		
		let subject = MultipeerSessionManager(sessionProvider: mockProvider, delegate: mockDelegate)
		subject.send(payload) { error in
			XCTAssertNil(error)
			sentWithoutFailure.fulfill()
		}
		waitForExpectations(timeout: 5.0, handler: nil)
	}
	
	func testMessageSendReceiveSuccessful() {
		let sentWithoutFailure = expectation(description: "Sending a message")
		let received = expectation(description: "Received a message")
		
		let mockProvider = MockMultipeerSessionProviding(myPeerName: "ME", with: ["PEER"])
		let mockDelegate = MockMultipeerSessionManagerDelegate()
		let payloadToSend = MultipeerMessagePayload(text: "test")
		
		mockProvider.sendHandler = { provider, data, peerIDs, mode in
			XCTAssertNotNil(provider.sessionDelegate)
			XCTAssertEqual(peerIDs, provider.connectedPeers)
			provider.sessionDelegate?.sessionProvider(provider, didReceive: data, fromPeer: provider.myPeerID)
		}
		mockDelegate.notifyReceivedPayloadHandler = { payload, peerID in
			XCTAssertEqual(payload.uuid, payloadToSend.uuid)
			XCTAssertEqual(peerID.displayName, "ME")
			received.fulfill()
		}
		
		let subject = MultipeerSessionManager(sessionProvider: mockProvider, delegate: mockDelegate)
		subject.send(payloadToSend) { error in
			XCTAssertNil(error)
			sentWithoutFailure.fulfill()
		}
		wait(for: [received, sentWithoutFailure], timeout: 5.0, enforceOrder: true)
	}
	
	func testMessageSendFailureEncodingError() {
		let sentWithFailure = expectation(description: "Failure to encode a message")
		
		let mockEncoder = MockCoreEncoding(encodingResult: .throwError(error: MockCoreEncodingError.forcedError))
		let mockProvider = MockMultipeerSessionProviding(myPeerName: "ME", with: ["PEER"])
		let mockDelegate = MockMultipeerSessionManagerDelegate()
		let payload = MultipeerMessagePayload(text: "test")
		
		let subject = MultipeerSessionManager(messageEncoder: mockEncoder, sessionProvider: mockProvider, delegate: mockDelegate)
		subject.send(payload, to: []) { error in
			XCTAssertNotNil(error)
			guard case MockCoreEncodingError.forcedError = error! else {
				XCTFail("Unexpected error: \(error!)")
				return
			}
			sentWithFailure.fulfill()
		}
		waitForExpectations(timeout: 5.0, handler: nil)
	}
	
	func testMessageSendFailureNoDestinationPeers() {
		let sentWithFailure = expectation(description: "Failure to send a message")
		
		let mockProvider = MockMultipeerSessionProviding(myPeerName: "ME", with: ["PEER"])
		let mockDelegate = MockMultipeerSessionManagerDelegate()
		let payload = MultipeerMessagePayload(text: "test")
		
		let subject = MultipeerSessionManager(sessionProvider: mockProvider, delegate: mockDelegate)
		subject.send(payload, to: []) { error in
			XCTAssertNotNil(error)
			guard case MCError.unsupported = error! else {
				XCTFail("Unexpected error: \(error!)")
				return
			}
			sentWithFailure.fulfill()
		}
		waitForExpectations(timeout: 5.0, handler: nil)
	}
	
	func testMessageReceiveFailureDecode() {
		let receivedWithFailure = expectation(description: "Error receiving a message")
		
		let mockDecoder = MockCoreDecoding(decodingResult: .throwError(error: MockCoreDecodingError.forcedError))
		let mockProvider = MockMultipeerSessionProviding(myPeerName: "ME", with: ["PEER"])
		let mockDelegate = MockMultipeerSessionManagerDelegate()
		let payloadToSend = MultipeerMessagePayload(text: "test")
		
		mockDelegate.notifyErrorDecodingMessageHandler = { error, peerID in
			XCTAssertEqual(peerID.displayName, "ME")
			XCTAssertNotNil(error)
			guard case MockCoreDecodingError.forcedError = error else {
				XCTFail("Unexpected error: \(error)")
				return
			}
			receivedWithFailure.fulfill()
		}
		
		let subject = MultipeerSessionManager(messageDecoder: mockDecoder, sessionProvider: mockProvider, delegate: mockDelegate)
		subject.send(payloadToSend) { error in
			XCTAssertNil(error)
		}
		waitForExpectations(timeout: 5.0, handler: nil)
	}

	func testMessageSendWithResourceSuccessful() {
		let sentWithoutFailure = expectation(description: "Sending a message")
		
		let mockProvider = MockMultipeerSessionProviding(myPeerName: "ME", with: ["PEER"])
		let mockDelegate = MockMultipeerSessionManagerDelegate()
		let payload = MultipeerMessagePayload(text: "test", resourceURL: URL(string: "http://example.com/"))
		
		let subject = MultipeerSessionManager(sessionProvider: mockProvider, delegate: mockDelegate)
		subject.send(payload) { error in
			XCTAssertNil(error)
			sentWithoutFailure.fulfill()
		}
		waitForExpectations(timeout: 5.0, handler: nil)
	}
	
	func testMessageSendWithResourceFailed() {
		let sentWithFailure = expectation(description: "Failure to send a message")
		
		let mockProvider = MockMultipeerSessionProviding(myPeerName: "ME", with: ["PEER"])
		let mockDelegate = MockMultipeerSessionManagerDelegate()
		let payload = MultipeerMessagePayload(text: "test", resourceURL: URL(string: "http://example.com/"))
		
		var recipientPeer: MCPeerID!
		mockProvider.sendResourceHandler = { provider, url, resourceName, peerID, completion in
			XCTAssertEqual(resourceName, "\(payload.uuid.uuidString)/\(url.lastPathComponent)")
			recipientPeer = peerID
			completion?(MCError(.timedOut))
			return nil
		}
		
		let subject = MultipeerSessionManager(sessionProvider: mockProvider, delegate: mockDelegate)
		subject.send(payload) { error in
			XCTAssertNotNil(error)
			guard case MultipeerMessageManagerError.partialErrors(let partialErrors) = error! else {
				XCTFail("Unexpected error: \(error!)")
				return
			}
			let partialError = partialErrors[recipientPeer]
			XCTAssertNotNil(partialError)
			guard case MCError.timedOut = partialError! else {
				XCTFail("Unexpected partial error: \(partialError!)")
				return
			}
			sentWithFailure.fulfill()
		}
		waitForExpectations(timeout: 5.0, handler: nil)
	}

	func testMessageSendReceiveWithResourceSuccessful() {
		let sentWithoutFailure = expectation(description: "Sending a message")
		let received = expectation(description: "Received a message")
		
		let mockProvider = MockMultipeerSessionProviding(myPeerName: "ME", with: ["PEER"])
		let mockDelegate = MockMultipeerSessionManagerDelegate()
		let payloadToSend = MultipeerMessagePayload(text: "test", resourceURL: URL(string: "http://example.com/"))
		
		mockProvider.sendHandler = { provider, data, peerIDs, mode in
			XCTAssertNotNil(provider.sessionDelegate)
			XCTAssertEqual(peerIDs, provider.connectedPeers)
			provider.sessionDelegate?.sessionProvider(provider, didReceive: data, fromPeer: provider.myPeerID)
		}
		mockDelegate.notifyReceivedPayloadHandler = { payload, peerID in
			XCTAssertEqual(payload.data, payloadToSend.data)
			XCTAssertEqual(payload.resourceURL, payloadToSend.resourceURL) // This is normally not true (but for tests, yes)
			XCTAssertEqual(payload.uuid, payloadToSend.uuid)
			XCTAssertEqual(peerID.displayName, "ME")
			received.fulfill()
		}
		
		let subject = MultipeerSessionManager(sessionProvider: mockProvider, delegate: mockDelegate)
		subject.send(payloadToSend) { error in
			XCTAssertNil(error)
			sentWithoutFailure.fulfill()
		}
		waitForExpectations(timeout: 5.0, handler: nil)
	}

	func testMessageSendReceiveWithResourceSuccessfulResourceComesFirst() {
		let sentWithoutFailure = expectation(description: "Sending a message")
		let received = expectation(description: "Received a message")
		
		let mockProvider = MockMultipeerSessionProviding(myPeerName: "ME", with: ["PEER"])
		let mockDelegate = MockMultipeerSessionManagerDelegate()
		let payloadToSend = MultipeerMessagePayload(text: "test", resourceURL: URL(string: "http://example.com/"))

		var payloadData: Data!
		mockProvider.sendHandler = { provider, data, peerIDs, mode in
			payloadData = data
		}
		mockProvider.sendResourceHandler = { provider, url, resourceName, peerID, completion in
			completion?(nil)
			provider.sessionDelegate?.sessionProvider(provider, didFinishReceivingResourceWithName: resourceName, fromPeer: provider.myPeerID, at: url, withError: nil)
			provider.sessionDelegate?.sessionProvider(provider, didReceive: payloadData, fromPeer: provider.myPeerID)
			return nil
		}
		mockDelegate.notifyReceivedPayloadHandler = { payload, peerID in
			XCTAssertEqual(payload.data, payloadToSend.data)
			XCTAssertEqual(payload.resourceURL, payloadToSend.resourceURL) // This is normally not true (but for tests, yes)
			XCTAssertEqual(payload.uuid, payloadToSend.uuid)
			XCTAssertEqual(peerID.displayName, "ME")
			received.fulfill()
		}
		
		let subject = MultipeerSessionManager(sessionProvider: mockProvider, delegate: mockDelegate)
		subject.send(payloadToSend) { error in
			XCTAssertNil(error)
			sentWithoutFailure.fulfill()
		}
		waitForExpectations(timeout: 5.0, handler: nil)
	}
	
	func testMessageReceiveWithResourceIgnoreBadResourceName() {
		let sentWithoutFailure = expectation(description: "Sending a message")
		let sentBadResourceName = expectation(description: "Sent bad resource name")
		let received = expectation(description: "Received a message")
		received.isInverted = true
		
		let mockProvider = MockMultipeerSessionProviding(myPeerName: "ME", with: ["PEER"])
		let mockDelegate = MockMultipeerSessionManagerDelegate()
		let payloadToSend = MultipeerMessagePayload(text: "test", resourceURL: URL(string: "http://example.com/"))
		
		mockProvider.sendHandler = { provider, data, peerIDs, mode in
			XCTAssertNotNil(provider.sessionDelegate)
			XCTAssertEqual(peerIDs, provider.connectedPeers)
			provider.sessionDelegate?.sessionProvider(provider, didReceive: data, fromPeer: provider.myPeerID)
		}
		mockProvider.sendResourceHandler = { provider, url, resourceName, peerID, completion in
			provider.sessionDelegate?.sessionProvider(provider, didFinishReceivingResourceWithName: "BAD RESOURCE NAME", fromPeer: provider.myPeerID, at: url, withError: nil)
			sentBadResourceName.fulfill()
			completion?(nil)
			return nil
		}
		mockDelegate.notifyReceivedPayloadHandler = { payload, peerID in
			received.fulfill()
		}
		
		let subject = MultipeerSessionManager(sessionProvider: mockProvider, delegate: mockDelegate)
		subject.send(payloadToSend) { error in
			XCTAssertNil(error)
			sentWithoutFailure.fulfill()
		}
		waitForExpectations(timeout: 2.0, handler: nil)
	}
	
	func testMessageReceiveWithResourceFailed() {
		let sentWithoutFailure = expectation(description: "Sending a message")
		let receivedError = expectation(description: "Received an error")
		
		let mockProvider = MockMultipeerSessionProviding(myPeerName: "ME", with: ["PEER"])
		let mockDelegate = MockMultipeerSessionManagerDelegate()
		let payloadToSend = MultipeerMessagePayload(text: "test", resourceURL: URL(string: "http://example.com/"))
		
		mockProvider.sendHandler = { provider, data, peerIDs, mode in
			XCTAssertNotNil(provider.sessionDelegate)
			XCTAssertEqual(peerIDs, provider.connectedPeers)
			provider.sessionDelegate?.sessionProvider(provider, didReceive: data, fromPeer: provider.myPeerID)
		}
		mockProvider.sendResourceHandler = { provider, url, resourceName, peerID, completion in
			let error = MCError(.timedOut)
			provider.sessionDelegate?.sessionProvider(provider, didFinishReceivingResourceWithName: resourceName, fromPeer: provider.myPeerID, at: url, withError: error)
			completion?(nil)
			return nil
		}
		mockDelegate.notifyErrorReceivingResourceHandler = { error, uuid, peerID in
			XCTAssertEqual(payloadToSend.uuid, uuid)
			XCTAssertEqual(mockProvider.myPeerID, peerID)
			guard case MCError.timedOut = error else {
				XCTFail("Unexpected error: \(error)")
				return
			}
			receivedError.fulfill()
		}
		
		let subject = MultipeerSessionManager(sessionProvider: mockProvider, delegate: mockDelegate)
		subject.send(payloadToSend) { error in
			XCTAssertNil(error)
			sentWithoutFailure.fulfill()
		}
		waitForExpectations(timeout: 5.0, handler: nil)
	}
	
	func testMessageReceiveWithResourceUnexpectedFailure() {
		let sentWithoutFailure = expectation(description: "Sending a message")
		let receivedError = expectation(description: "Received an error")
		
		let mockProvider = MockMultipeerSessionProviding(myPeerName: "ME", with: ["PEER"])
		let mockDelegate = MockMultipeerSessionManagerDelegate()
		let payloadToSend = MultipeerMessagePayload(text: "test", resourceURL: URL(string: "http://example.com/"))
		
		mockProvider.sendHandler = { provider, data, peerIDs, mode in
			XCTAssertNotNil(provider.sessionDelegate)
			XCTAssertEqual(peerIDs, provider.connectedPeers)
			provider.sessionDelegate?.sessionProvider(provider, didReceive: data, fromPeer: provider.myPeerID)
		}
		mockProvider.sendResourceHandler = { provider, url, resourceName, peerID, completion in
			provider.sessionDelegate?.sessionProvider(provider, didFinishReceivingResourceWithName: resourceName, fromPeer: provider.myPeerID, at: nil, withError: nil)
			completion?(nil)
			return nil
		}
		mockDelegate.notifyErrorReceivingResourceHandler = { error, uuid, peerID in
			XCTAssertEqual(payloadToSend.uuid, uuid)
			XCTAssertEqual(mockProvider.myPeerID, peerID)
			guard case MultipeerMessageManagerError.unexpectedError = error else {
				XCTFail("Unexpected error: \(error)")
				return
			}
			receivedError.fulfill()
		}
		
		let subject = MultipeerSessionManager(sessionProvider: mockProvider, delegate: mockDelegate)
		subject.send(payloadToSend) { error in
			XCTAssertNil(error)
			sentWithoutFailure.fulfill()
		}
		waitForExpectations(timeout: 5.0, handler: nil)
	}
	
	func testMessageReceiveWithResourceCopyFailure() {
		let sentWithoutFailure = expectation(description: "Sending a message")
		let receivedError = expectation(description: "Received an error")
		
		let mockProvider = MockMultipeerSessionProviding(myPeerName: "ME", with: ["PEER"])
		let mockDelegate = MockMultipeerSessionManagerDelegate()
		let payloadToSend = MultipeerMessagePayload(text: "test", resourceURL: URL(string: "http://example.com/"))
		
		mockDelegate.copyResourceHandler = { name, url in
			throw MCError(.invalidParameter)
		}
		mockDelegate.notifyErrorReceivingResourceHandler = { error, uuid, peerID in
			XCTAssertEqual(payloadToSend.uuid, uuid)
			XCTAssertEqual(mockProvider.myPeerID, peerID)
			guard case MCError.invalidParameter = error else {
				XCTFail("Unexpected error: \(error)")
				return
			}
			receivedError.fulfill()
		}
		
		let subject = MultipeerSessionManager(sessionProvider: mockProvider, delegate: mockDelegate)
		subject.send(payloadToSend) { error in
			XCTAssertNil(error)
			sentWithoutFailure.fulfill()
		}
		waitForExpectations(timeout: 5.0, handler: nil)
	}
}

extension MultipeerMessagePayload {
	
	init(text: String, resourceURL: URL? = nil) {
		self.init(with: text.data(using: .utf8)!, resource: resourceURL)
	}
}

#endif
