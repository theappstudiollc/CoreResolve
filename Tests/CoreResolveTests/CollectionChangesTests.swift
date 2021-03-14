//
//  CollectionChangesTests.swift
//  CoreResolve
//
//  Created by David Mitchell
//  Copyright © 2020 The App Studio LLC.
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
import CoreResolve

final class CollectionChangesTests: XCTestCase {

    func testCollectionChanges() throws {
		var source = [Int].generateRandomUnique(50, range: 0..<100).map { ResultHashable(value: $0) }
		let destination = [Int].generateRandomUnique(60, range: 0..<100).map { ResultHashable(value: $0) }

		print("Source = \(source)")
		print("Destination = \(destination)")

		// Obtain the CollectionChanges for the source and destination
		let changes = source.collectionChanges(to: destination)
		print("Changes = deletes: \(changes.deletes.count), moves: \(changes.moves.count), inserts: \(changes.inserts.count), reloads: \(changes.reloads.count)")

		// Collect unique indices for all properties in CollectionChanges
		let deletes = Set(changes.deletes)
		let inserts = Set(changes.inserts)
		let moveTos = Set(changes.moves.map({ $0.to }))
		let moveFroms = Set(changes.moves.map({ $0.from }))
		let reloads = Set(changes.reloads)

		// Check for no duplicates of deletes, inserts, moves, or reloads
		XCTAssertEqual(changes.deletes.count, deletes.count)
		XCTAssertEqual(changes.inserts.count, inserts.count)
		XCTAssertEqual(changes.moves.count, moveTos.count)
		XCTAssertEqual(changes.moves.count, moveFroms.count)
		XCTAssertEqual(changes.reloads.count, reloads.count)

		// Check that no moves are sourced from a delete
		XCTAssert(moveFroms.intersection(deletes).count == 0)

		// Check that no moves apply to the same destination as an insert
		XCTAssert(moveTos.intersection(inserts).count == 0)

		// Check that reloads does not contain inserts
		XCTAssert(reloads.intersection(inserts).count == 0)

		// Apply the changes to the source and check that the result matches the destination
		source.applyChanges(changes, using: destination)
		XCTAssertEqual(source, destination)
    }

    func testPerformanceExample() throws {
		var source = [Int].generateRandomUnique(500, range: 0..<1000).map { ResultHashable(value: $0) }
		let destination = [Int].generateRandomUnique(600, range: 0..<1000).map { ResultHashable(value: $0) }

		var changes: CollectionChanges<[ResultHashable]>! = nil
		self.measure {
			changes = source.collectionChanges(to: destination)
        }
		print("Changes = deletes: \(changes.deletes.count), moves: \(changes.moves.count), inserts: \(changes.inserts.count), reloads: \(changes.reloads.count)")
		source.applyChanges(changes, using: destination)

		XCTAssertEqual(source, destination)
    }
}

struct ResultHashable: Hashable, CustomDebugStringConvertible {
	let value: Int
	var debugDescription: String { "\(value)" }
}

extension Array where Element == Int {

	static func generateRandomUnique(_ count: Int, range: Range<Element>) -> [Element] {
		assert(count < range.endIndex - range.startIndex)
		var result = range.map({ $0 }).shuffled()
		while result.count > count {
			result.remove(at: Int.random(in: 0..<result.count))
		}
		return result
	}
}

extension Array where Element == ResultHashable {

	mutating func applyChanges(_ collectionChanges: CollectionChanges<Self>, using elements: [Element]) {
		let resultCount = count - collectionChanges.deletes.count + collectionChanges.inserts.count
		var result = Array(repeating: ResultHashable(value: -1), count: resultCount)
		for index in collectionChanges.deletes {
			self[index] = ResultHashable(value: -2) // Ensure we don't copy these values over
		}
		for index in collectionChanges.inserts {
			result[index] = elements[index]
		}
		for move in collectionChanges.moves {
			result[move.to] = self[move.from]
		}
		let moveTos = Set(collectionChanges.moves.map({ $0.to }))
		for index in collectionChanges.reloads.filter({ !moveTos.contains($0) }) {
			result[index] = elements[index]
		}
		self = result
	}

	var debugDescription: String { "[\(map({"\($0.value)"} ).joined(separator: ", "))]" }
}

#endif
