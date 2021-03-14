//
//  Extensions.swift
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

import Foundation

public extension Comparable {
	
	func bounded(by limits: ClosedRange<Self>) -> Self {
		return min(max(self, limits.lowerBound), limits.upperBound)
	}
}

public extension Data {
	
	func secureDecode<T: AnyObject>(_ objectType: T.Type, including otherTypes: [AnyClass]? = nil) throws -> T {
		let unarchiver: NSKeyedUnarchiver
		if #available(iOS 11.0, macOS 10.13, tvOS 11.0, watchOS 4.0, *) {
			unarchiver = try NSKeyedUnarchiver(forReadingFrom: self)
		} else {
			unarchiver = NSKeyedUnarchiver(forReadingWith: self)
		}
		unarchiver.requiresSecureCoding = true
		var objectTypes: [AnyClass] = [objectType]
		if let otherTypes = otherTypes {
			objectTypes.append(contentsOf: otherTypes)
		}
		let retVal = try unarchiver.decodeTopLevelObject(of: objectTypes, forKey: NSKeyedArchiveRootObjectKey)
		unarchiver.finishDecoding()
		if let error = unarchiver.error {
			throw error
		}
		return retVal as! T
	}
}

public extension DispatchQueue {
	
	class func runInMain(_ block: () -> Void) {
		if Thread.isMainThread {
			block()
		} else {
			main.sync(execute: block)
		}
	}
}

public extension FileManager {
	
	func moveFileCreatingDirectories(from source: URL, to destination: URL) throws {
		let coordinator = NSFileCoordinator(filePresenter: nil)
		let directoryURL = destination.deletingLastPathComponent()
		try coordinator.coordinateWrite(at: directoryURL, options: .forDeleting) { writingURL in
			try createDirectory(at: writingURL, withIntermediateDirectories: true, attributes: nil)
		}
		try coordinator.coordinateWrite(at: destination, options: .forMoving) { writingURL in
			try moveItem(at: source, to: writingURL)
		}
	}
}

public extension NotificationCenter {

	func listen(forName name: Notification.Name, on object: Any? = nil, handler: @escaping (_ notification: Notification, _ stopListening: () -> Void) -> Void) -> () -> Void {
		var observer: NSObjectProtocol? = nil
		let retVal = {
			self.removeObserver(observer!)
		}
		observer = addObserver(forName: name, object: object, queue: nil) { (_ notification: Notification) in
			handler(notification, retVal)
		}
		return retVal
	}
}

public extension NSFileCoordinator {
	
	func coordinateWrite(at directoryURL: URL, options: WritingOptions, closure: (URL) throws -> Void) throws {
		var coordinatorError: NSError?
		var closureError: Error?
		coordinate(writingItemAt: directoryURL, options: options, error: &coordinatorError) { writingURL in
			do {
				try closure(writingURL)
			} catch {
				closureError = error
			}
		}
		if let error = coordinatorError {
			throw error
		} else if let error = closureError {
			throw error
		}
	}
}

public extension UserDefaults {
	
	func secureDecode<T>(_ type: T.Type, including otherTypes: [AnyClass]? = nil, forKey key: String) throws -> T? where T: AnyObject {
		guard let data = data(forKey: key) else { return nil }
		return try data.secureDecode(type, including: otherTypes)
	}
	
	func secureEncode<T>(_ value: T, forKey key: String) throws {
		let data: Data
		if #available(iOS 11.0, macOS 10.13.0, tvOS 11.0, watchOS 4.0, *) {
			data = try NSKeyedArchiver.archivedData(withRootObject: value, requiringSecureCoding: true)
		} else {
			data = NSKeyedArchiver.archivedData(withRootObject: value)
		}
		set(data, forKey: key)
	}
}
