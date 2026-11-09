//
//  FileStoreManagerTests.swift
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

struct FileStoreManagerTests {
    private struct Provider: CoreFileStoreManagerUrlProviding {
        let root: URL?
        var excluded: Bool? = nil
        func directoryUrl(for directoryType: CoreFileStoreDirectoryType) -> URL? { root }
        func shouldExcludeForBackup(directoryType: CoreFileStoreDirectoryType) -> Bool? { excluded }
    }

    private func withDirectory(_ body: (URL) throws -> Void) throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }
        try body(root)
    }

    @Test(arguments: ["Experiments", "Experiments/Photos", "Photo experiments/日本語"])
    func createsDocumentsSubpaths(subpath: String) throws {
        try withDirectory { root in
            let manager = FileStoreManager(urlProvider: Provider(root: root))
            try manager.ensureDirectoryExists(for: .documents, withSubpath: subpath)
            let directory = root.appendingPathComponent(subpath)
            #expect(try directory.resourceValues(forKeys: [.isDirectoryKey]).isDirectory == true)
            // Mirrors Resolve's next step: save an image into the requested directory.
            let file = directory.appendingPathComponent("image.jpg")
            let data = Data([1, 2, 3])
            try data.write(to: file, options: .withoutOverwriting)
            #expect(try Data(contentsOf: file) == data)
        }
    }

    @Test(arguments: [CoreFileStoreDirectoryType.cache, .applicationSupport, .applicationReserved0])
    func createsOtherDirectoriesAndIntermediatePaths(type: CoreFileStoreDirectoryType) throws {
        try withDirectory { root in
            let destination = root.appendingPathComponent("new-root")
            let manager = FileStoreManager(urlProvider: Provider(root: destination))
            try manager.ensureDirectoryExists(for: type, withSubpath: "one/two")
            #expect(try destination.appendingPathComponent("one/two")
                .resourceValues(forKeys: [.isDirectoryKey]).isDirectory == true)
        }
    }

    @Test func repeatedCreationPreservesExistingFiles() throws {
        try withDirectory { root in
            let manager = FileStoreManager(urlProvider: Provider(root: root))
            try manager.ensureDirectoryExists(for: .documents, withSubpath: "Experiments")
            let file = root.appendingPathComponent("Experiments/image.jpg")
            let data = Data([4, 5, 6])
            try data.write(to: file)
            try manager.ensureDirectoryExists(for: .documents, withSubpath: "Experiments")
            #expect(try Data(contentsOf: file) == data)
        }
    }

    @Test func documentsWithoutSubpathDoesNotRequireProviderLookup() throws {
        let manager = FileStoreManager(urlProvider: Provider(root: nil))
        try manager.ensureDirectoryExists(for: .documents)
        try manager.ensureDirectoryExists(for: .documents, withSubpath: "")
    }

    @Test func unknownDirectoryThrows() {
        let manager = FileStoreManager(urlProvider: Provider(root: nil))
        #expect(throws: CoreFileStoreServiceError.self) {
            try manager.directoryUrl(for: .applicationReserved0)
        }
        #expect(throws: CoreFileStoreServiceError.self) {
            try manager.ensureDirectoryExists(for: .documents, withSubpath: "Experiments")
        }
    }

    @Test func fileBlockingIntermediateDirectoryThrows() throws {
        try withDirectory { root in
            try Data([1]).write(to: root.appendingPathComponent("blocked"))
            let manager = FileStoreManager(urlProvider: Provider(root: root))
            #expect(throws: (any Error).self) {
                try manager.ensureDirectoryExists(for: .documents, withSubpath: "blocked/photos")
            }
        }
    }

    @Test(arguments: [true, false])
    func appliesBackupPolicy(excluded: Bool) throws {
        try withDirectory { root in
            let directory = root.appendingPathComponent("cache")
            let manager = FileStoreManager(urlProvider: Provider(root: directory, excluded: excluded))
            try manager.ensureDirectoryExists(for: .cache)
            #expect(try directory.resourceValues(forKeys: [.isExcludedFromBackupKey])
                .isExcludedFromBackup == excluded)
        }
    }
}
