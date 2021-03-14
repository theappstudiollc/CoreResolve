//
//  CollectionChanges.swift
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

import Foundation

/// Represents the changes needed to modify one collection to make it equal to another. This struct does not represent reversable changes
public struct CollectionChanges<C> where C: Collection {

	/// The delete operations needed, by index
	public var deletes: [C.Index]

	/// The insert operations needed, by index
	public var inserts: [C.Index]

	/// The move operations needed, from a source index to destination index
	public var moves: [(from: C.Index, to: C.Index)]

	// The indices that are not refreshed between the two collections (based on the final indices)
	public var reloads: [C.Index]
}

public extension Collection where Element: Hashable, Index == Int {

	/// Returns the `CollectionChanges` needed to conver the source to the destination, when the `Collection.Element` is `Hashable`
	/// - Parameter collection: The destination collection
	/// - Returns: A `CollectionChanges` struct
	func collectionChanges(to collection: Self) -> CollectionChanges<Self> {

		let newIndices = Dictionary<Element, Index>(uniqueKeysWithValues: zip(collection, collection.indices))

		let insertionIndices = newIndices.compactMap { key, value in
			return contains(key) ? nil : value
		}

		let deletionIndices = enumerated().compactMap { index, element in
			collection.contains(element) ? nil : index
		}

		var moveIndices = [(from: Index, to: Index)]()
		var reloadIndices = [Index]()

		reloadIndices.reserveCapacity(count)
		moveIndices.reserveCapacity(count / 2)

		for (index, element) in enumerated() {
			guard let newIndex = newIndices[element] else { continue }
			// Adjust index and newIndex by deletions and inserts so that we can reduce the number of moves
			let adjustedSource = index - deletionIndices.sortedCount(below: index) + insertionIndices.sortedCount(below: index + 1)
			if adjustedSource != newIndex {
				moveIndices.append((index, newIndex))
			}
			reloadIndices.append(newIndex)
		}

		return CollectionChanges(deletes: deletionIndices, inserts: insertionIndices, moves: moveIndices, reloads: reloadIndices)
	}
}

fileprivate extension Array where Element == Int {

	/// Returns the count of elements less than the parameter value, provided that the array is sorted in ascending order
	/// - Parameter value: The value to test how many elements within the array are less than
	/// - Returns: The count of elements less than the parameter value
	func sortedCount(below value: Int) -> Int {
		guard let first = first, first < value else {
			return 0
		}
		for (index, element) in enumerated() {
			guard element < value else { return index + 1 }
		}
		return count
	}
}
