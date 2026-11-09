#if canImport(MultipeerConnectivity)
import MultipeerConnectivity
import Testing
@testable import CoreResolve

struct MultipeerTrustPolicyTests {
    private func decision(for session: MockMultipeerSessionProviding, certificate: [Any]?, peer: MCPeerID) throws -> Bool {
        let delegate = try #require(session.sessionDelegate)
        var decisions: [Bool] = []
        delegate.sessionProvider(session, didReceiveCertificate: certificate, fromPeer: peer) {
            decisions.append($0)
        }
        try #require(decisions.count == 1, "Trust must be decided synchronously and exactly once")
        return decisions[0]
    }

    @Test func defaultPreservesAcceptanceWithAndWithoutCertificate() throws {
        let session = MockMultipeerSessionProviding(myPeerName: "local", with: [])
        let manager = MultipeerMessageManager(with: nil, resourceContainer: nil)
        manager.sessionProvider = session
        let peer = MCPeerID(displayName: "remote")
        #expect(try decision(for: session, certificate: nil, peer: peer))
        #expect(try decision(for: session, certificate: ["fixture"], peer: peer))
        withExtendedLifetime(manager) {}
    }

    @Test func customPolicyReceivesCertificateAndPeerAndControlsDecision() throws {
        let session = MockMultipeerSessionProviding(myPeerName: "local", with: [])
        let manager = MultipeerMessageManager(with: nil, resourceContainer: nil)
        let trustedPeer = MCPeerID(displayName: "trusted")
        var calls = 0
        // Fixture strings exercise forwarding only; production policies must validate real identities.
        manager.certificateValidationHandler = { certificate, peer in
            calls += 1
            return peer == trustedPeer && certificate as? [String] == ["trusted-fixture"]
        }
        manager.sessionProvider = session
        #expect(try decision(for: session, certificate: ["trusted-fixture"], peer: trustedPeer))
        #expect(try !decision(for: session, certificate: ["untrusted-fixture"], peer: trustedPeer))
        #expect(try !decision(for: session, certificate: nil, peer: trustedPeer))
        #expect(try !decision(for: session, certificate: ["trusted-fixture"], peer: MCPeerID(displayName: "other")))
        #expect(calls == 4)
        withExtendedLifetime(manager) {}
    }

    @Test func policyPersistsAcrossSessionReplacementAndCanBeCleared() throws {
        let manager = MultipeerMessageManager(with: nil, resourceContainer: nil)
        let first = MockMultipeerSessionProviding(myPeerName: "first", with: [])
        manager.sessionProvider = first
        // Configure while disconnected, before any delegate callbacks begin.
        manager.certificateValidationHandler = { _, _ in false }
        let peer = MCPeerID(displayName: "remote")
        #expect(try !decision(for: first, certificate: nil, peer: peer))
        let second = MockMultipeerSessionProviding(myPeerName: "second", with: [])
        manager.sessionProvider = second
        #expect(try !decision(for: second, certificate: nil, peer: peer))
        manager.certificateValidationHandler = nil
        #expect(try decision(for: second, certificate: nil, peer: peer))
        withExtendedLifetime(manager) {}
    }
}
#endif
