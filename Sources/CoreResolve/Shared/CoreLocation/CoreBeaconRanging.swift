//
//  CoreBeaconRanging.swift
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

#if !os(tvOS) && !os(watchOS)

import CoreLocation

public protocol CoreBeaconRanging {
	
	/// Starts calculating ranges for beacons in the specified region.
	/// - Parameter constraint: The `CoreBeaconIdentityConstraint` describing the region for which to calculate ranges.
	func startRangingBeacons(with constraint: CoreBeaconIdentityConstraint)
	
	/// Stops calculating ranges for the specified region.
	/// - Parameter constraint: The `CoreBeaconIdentityConstraint` describing the region for which to stop calculate ranges.
	func stopRangingBeacons(with constraint: CoreBeaconIdentityConstraint)
}

public struct CoreBeaconIdentityConstraint: Equatable, Hashable {
	
	public let uuid: UUID
	public let major: CLBeaconMajorValue?
	public let minor: CLBeaconMinorValue?
	
	public init(uuid: UUID, major: CLBeaconMajorValue?, minor: CLBeaconMinorValue?) {
		self.uuid = uuid
		self.major = major
		self.minor = minor
	}
}

#if !os(macOS) || swift(>=5.3) // not mac or Xcode 12.x

public extension CoreBeaconIdentityConstraint {
	
	@available(iOS 13.0, macOS 10.15, *)
	init(constraint: CLBeaconIdentityConstraint) {
		#if targetEnvironment(macCatalyst) || os(macOS)
		self.init(uuid: constraint.uuid, major: nil, minor: nil)
		#else
		self.init(uuid: constraint.uuid, major: constraint.major, minor: constraint.minor)
		#endif
	}
	
	@available(iOS, deprecated: 13.0)
	@available(macOS 10.15, *)
	init(region: CLBeaconRegion) {
		self.init(uuid: region.proximityUUID, major: region.major?.uint16Value, minor: region.minor?.uint16Value)
	}
}

public extension CoreBeaconIdentityConstraint {
	
	@available(iOS 13.0, macOS 10.15, *)
	var identityConstraint: CLBeaconIdentityConstraint {
		switch (major, minor) {
		case (.some(let majorValue), .some(let minorValue)):
			return CLBeaconIdentityConstraint(uuid: uuid, major: majorValue, minor: minorValue)
		case (.some(let majorValue), _):
			return CLBeaconIdentityConstraint(uuid: uuid, major: majorValue)
		default:
			return CLBeaconIdentityConstraint(uuid: uuid)
		}
	}
	
	@available(iOS, deprecated: 13.0)
	@available(macOS 10.15, *)
	var region: CLBeaconRegion {
		switch (major, minor) {
		case (.some(let majorValue), .some(let minorValue)):
			return CLBeaconRegion(proximityUUID: uuid, major: majorValue, minor: minorValue, identifier: regionIdentifier)
		case (.some(let majorValue), _):
			return CLBeaconRegion(proximityUUID: uuid, major: majorValue, identifier: regionIdentifier)
		default:
			return CLBeaconRegion(proximityUUID: uuid, identifier: regionIdentifier)
		}
	}
	
	var regionIdentifier: String {
		switch (major, minor) {
		case (.some(let majorValue), .some(let minorValue)):
			return "\(uuid).\(majorValue).\(minorValue)"
		case (.some(let majorValue), _):
			return "\(uuid).\(majorValue).nil"
		default:
			return "\(uuid).nil.nil"
		}
	}
}

#endif

#endif
