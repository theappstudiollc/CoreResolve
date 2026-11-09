//
//  ServiceLifetimeTests.swift
//  CoreResolve
//
//  Created by David Mitchell
//  Copyright © 2026 The App Studio LLC.
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

import Testing
@testable import CoreResolve

struct ServiceLifetimeTests {
    private final class Service { }
    private enum Failure: Error { case unavailable }

    @Test func lookupDoesNotInitializeService() {
        let manager = ServiceManager()
        var calls = 0
        manager.registerService(withIdentifier: "service") { calls += 1; return Service() }
        #expect(manager.resolveServiceIfLoaded(withIdentifier: "service") == nil)
        #expect(manager.resolveServiceIfLoaded(withIdentifier: "missing") == nil)
        #expect(calls == 0)
    }

    @Test func failedInitializerCanBeRetried() throws {
        let manager = ServiceManager()
        var calls = 0
        manager.registerService(withIdentifier: "service") {
            calls += 1
            if calls == 1 { throw Failure.unavailable }
            return Service()
        }
        #expect(throws: CoreServiceProvidingError.self) {
            try manager.resolveService(withIdentifier: "service")
        }
        #expect(manager.resolveServiceIfLoaded(withIdentifier: "service") == nil)
        let service = try #require(manager.resolveService(withIdentifier: "service") as? Service)
        #expect(try manager.resolveService(withIdentifier: "service") as? Service === service)
        #expect(calls == 2)
    }

    @Test func resolvingAfterReleaseRetainsServiceAgain() throws {
        let manager = ServiceManager()
        manager.registerService(withIdentifier: "service") { Service() }
        var retained: Service? = try #require(manager.resolveService(withIdentifier: "service") as? Service)
        let reference = { [weak retained] in retained }
        manager.releaseUnusedServices()
        #expect(reference() != nil)
        _ = try manager.resolveService(withIdentifier: "service")
        retained = nil
        #expect(reference() != nil)
        manager.releaseUnusedServices()
        #expect(reference() == nil)
        #expect(manager.resolveServiceIfLoaded(withIdentifier: "service") == nil)
    }

    @Test func registrationReplacementAppliesAfterCachedServiceIsReleased() throws {
        let manager = ServiceManager()
        var originalCalls = 0
        var replacementCalls = 0
        manager.registerService(withIdentifier: "service") { originalCalls += 1; return Service() }
        _ = try manager.resolveService(withIdentifier: "service")
        manager.registerService(withIdentifier: "service") { replacementCalls += 1; return Service() }
        _ = try manager.resolveService(withIdentifier: "service")
        #expect(originalCalls == 1)
        #expect(replacementCalls == 0)
        manager.releaseUnusedServices()
        _ = try manager.resolveService(withIdentifier: "service")
        #expect(replacementCalls == 1)
    }

    @Test func aliasAndDependencyResolutionReuseSameService() throws {
        let manager = ServiceManager()
        var calls = 0
        manager.registerService(withIdentifier: "data") { calls += 1; return Service() }
        // Matches Resolve's CoreDataService -> DataService alias registration.
        manager.registerService(withIdentifier: "alias") { [unowned manager] in
            try manager.resolveService(withIdentifier: "data")
        }
        let alias = try #require(manager.resolveService(withIdentifier: "alias") as? Service)
        let data = try #require(manager.resolveService(withIdentifier: "data") as? Service)
        #expect(alias === data)
        #expect(calls == 1)
    }

    @Test func replacingFactoryUsesNewFactoryOnNextInvocation() throws {
        let registry = FactoryRegistry()
        registry.registerFactory(withIdentifier: "value") { 1 }
        #expect(try registry.invokeFactory(withIdentifier: "value") as? Int == 1)
        registry.registerFactory(withIdentifier: "value") { 2 }
        #expect(try registry.invokeFactory(withIdentifier: "value") as? Int == 2)
    }
}
