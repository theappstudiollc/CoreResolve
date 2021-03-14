//
//  CoreFileStoreManagerUrlProviderTests.swift
//  CoreResolveTests
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

#if !os(watchOS)

import XCTest
@testable import CoreResolve

final class CoreFileStoreManagerUrlProviderTests: XCTestCase {
	
	var bundle: Bundle!
	var bundleIdentifier: String!
	var urlProvider: CoreFileStoreManagerUrlProvider!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
		bundle = Bundle(for: CoreFileStoreManagerUrlProviderTests.self)
		bundleIdentifier = bundle.bundleIdentifier ?? ""
		urlProvider = CoreFileStoreManagerUrlProvider(applicationBundle: bundle)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
	
	func getApplicationSupportUrl() -> URL {
		return getLibraryUrl().appendingPathComponent("Application Support", isDirectory: true)
	}
	
	func getCachesUrl() -> URL {
		return getLibraryUrl().appendingPathComponent("Caches", isDirectory: true)
	}

	func getLibraryUrl() -> URL {
		return FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first!
	}
	
	func basicUrlAsserts(forUrl url: URL?) {
		XCTAssertNotNil(url)
		XCTAssert(url?.isFileURL ?? false)
		XCTAssert(url?.hasDirectoryPath ?? false)
	}
	
	func testCaseSetup() {
		XCTAssert(getApplicationSupportUrl().isFileURL)
		XCTAssert(getLibraryUrl().isFileURL)
	}
	
	func testApplicationReservedDirectories() {
		XCTAssertNil(urlProvider.directoryUrl(for: .applicationReserved0))
		XCTAssertNil(urlProvider.directoryUrl(for: .applicationReserved1))
		XCTAssertNil(urlProvider.directoryUrl(for: .applicationReserved2))
		XCTAssertNil(urlProvider.directoryUrl(for: .applicationReserved3))
		XCTAssertNil(urlProvider.directoryUrl(for: .applicationReserved4))
		XCTAssertNil(urlProvider.directoryUrl(for: .applicationReserved5))
		XCTAssertNil(urlProvider.directoryUrl(for: .applicationReserved6))
		XCTAssertNil(urlProvider.directoryUrl(for: .applicationReserved7))
	}
	
    func testApplicationSupportDirectory() {
		let directoryUrl = urlProvider.directoryUrl(for: .applicationSupport)
		basicUrlAsserts(forUrl: directoryUrl)
		let expectedResult = getApplicationSupportUrl().appendingPathComponent(bundleIdentifier, isDirectory: true)
		XCTAssertEqual(directoryUrl?.absoluteString, expectedResult.absoluteString)
    }
	
	func testApplicationSupportDirectoryBackup() {
		let shouldBackup = urlProvider.shouldExcludeForBackup(directoryType: .applicationSupport)
		XCTAssert(shouldBackup != nil && shouldBackup! == true) // ApplicationSupport should back up
	}
	
	func testCacheDirectory() {
		let directoryUrl = urlProvider.directoryUrl(for: .cache)
		basicUrlAsserts(forUrl: directoryUrl)
		let expectedResult = getCachesUrl().appendingPathComponent(bundleIdentifier, isDirectory: true)
		XCTAssertEqual(directoryUrl?.absoluteString, expectedResult.absoluteString)
	}
	
	func testCacheDirectoryBackup() {
		let shouldBackup = urlProvider.shouldExcludeForBackup(directoryType: .cache)
		XCTAssert(shouldBackup != nil && shouldBackup! == true) // Cache should back up
	}
	
	func testUserDocumentsDirectory() {
		let directoryUrl = urlProvider.directoryUrl(for: .documents)
		basicUrlAsserts(forUrl: directoryUrl)
		let expectedResult = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
		XCTAssertEqual(directoryUrl?.absoluteString, expectedResult.absoluteString)
	}
	
	func testUserDocumentsDirectoryBackup() {
		let shouldBackup = urlProvider.shouldExcludeForBackup(directoryType: .documents)
		XCTAssertNil(shouldBackup) // User Documents is already configured and no change should be made
	}
}

#endif
