//
//  CoreResettable.swift
//  CoreResolve
//
//  Created by David Mitchell
//  Copyright © 2019 The App Studio LLC.
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

/// Represents an entity that can undo its configuration, for example when no longer needed
public protocol CoreResettable {
	
	func reset()
}

/*
	MARK: - Collection, where Self.Element: CoreResettable
	Give CoreResettable capability to Collections of CoreResettable, when they are marked with CoreResettable
*/
extension CoreResettable where Self: Collection, Self.Element: CoreResettable {
	
	public func reset() {
		forEach { $0.reset() }
	}
}

/*
	MARK: - CoreResettable where Element: CoreResettable
	Give Arrays of CoreResettable its own CoreResettable conformance
*/
extension Array: CoreResettable where Element: CoreResettable { }
