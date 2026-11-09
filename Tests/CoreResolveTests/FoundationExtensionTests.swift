//
//  FoundationExtensionTests.swift
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

import Foundation
import Testing
@testable import CoreResolve

struct FoundationExtensionTests {
    @Test(arguments: [(-5, 0), (0, 0), (4, 4), (10, 10), (15, 10)])
    func boundsValues(input: Int, expected: Int) {
        #expect(input.bounded(by: 0...10) == expected)
    }

    @Test func notificationListenerCanStopFromHandler() {
        let center = NotificationCenter()
        let name = Notification.Name("test")
        var received = 0
        let stop = center.listen(forName: name) { notification, stopListening in
            #expect(notification.name == name)
            received += 1
            stopListening()
        }
        defer { stop() }
        center.post(name: name, object: nil)
        center.post(name: name, object: nil)
        #expect(received == 1)
    }

    @Test func notificationListenerFiltersSenderAndSupportsExternalStop() {
        let center = NotificationCenter()
        let sender = NSObject()
        let name = Notification.Name("test")
        var received = 0
        let stop = center.listen(forName: name, on: sender) { _, _ in received += 1 }
        defer { stop() }
        center.post(name: name, object: NSObject())
        center.post(name: name, object: sender)
        stop()
        center.post(name: name, object: sender)
        #expect(received == 1)
    }

    @Test func secureDefaultsRoundTripAndMissingKey() throws {
        let suite = "CoreResolveTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        #expect(try defaults.secureDecode(NSString.self, forKey: "missing") == nil)
        try defaults.secureEncode("original" as NSString, forKey: "value")
        #expect(try defaults.secureDecode(NSString.self, forKey: "value") == "original")
        try defaults.secureEncode("replacement" as NSString, forKey: "value")
        #expect(try defaults.secureDecode(NSString.self, forKey: "value") == "replacement")
    }

    @Test func movingFileCreatesIntermediateDirectoriesAndPreservesContents() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }
        let source = root.appendingPathComponent("source")
        let destination = root.appendingPathComponent("one/two/destination")
        let data = Data([1, 3, 5, 7])
        try data.write(to: source)
        try FileManager.default.moveFileCreatingDirectories(from: source, to: destination)
        #expect(!FileManager.default.fileExists(atPath: source.path))
        #expect(try Data(contentsOf: destination) == data)
    }

    @Test func coordinatedWritePropagatesClosureError() throws {
        enum Failure: Error, Equatable { case write }
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }
        #expect(throws: Failure.write) {
            try NSFileCoordinator(filePresenter: nil).coordinateWrite(at: root, options: .forDeleting) { _ in
                throw Failure.write
            }
        }
    }
}
