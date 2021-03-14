//
//  CoreBeaconIdentity.swift
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

import CoreLocation

public protocol CoreBeaconIdentity {

	var uuid: UUID { get }
	var major: CLBeaconMajorValue { get }
	var minor: CLBeaconMajorValue { get }
}

public extension CoreBeaconIdentity {

	#if os(iOS)

	func beaconRegion(identifier: String) -> CLBeaconRegion {
		guard #available(iOS 13.0, *) else {
			return CLBeaconRegion(proximityUUID: uuid, major: major, minor: minor, identifier: identifier)
		}
		return CLBeaconRegion(uuid: uuid, major: major, minor: minor, identifier: identifier)
	}

	func peripheralData(with measuredPower: Int8? = nil) -> [String : Any] {
		let region = self.beaconRegion(identifier: uuid.uuidString)
		if let measuredPower = measuredPower {
			return region.peripheralData(withMeasuredPower: NSNumber(value: measuredPower)) as! [String : Any]
		}
		return region.peripheralData(withMeasuredPower: nil) as! [String : Any]
	}

	#else

	func peripheralData(with measuredPower: Int8? = nil) -> [String : Any] {
		var advertisementBytes = [CUnsignedChar](repeating: 0, count: 21)

		(uuid as NSUUID).getBytes(&advertisementBytes)
		advertisementBytes[16] = CUnsignedChar(major >> 8)
		advertisementBytes[17] = CUnsignedChar(major & 0xFF)
		advertisementBytes[18] = CUnsignedChar(minor >> 8)
		advertisementBytes[19] = CUnsignedChar(minor & 0xFF)
		advertisementBytes[20] = CUnsignedChar(bitPattern: Int8(measuredPower ?? -58))
		let data = Data(bytes: advertisementBytes, count: 21)

		var result: [String : Data] = [:]
		result["kCBAdvDataAppleBeaconKey"] = data
		return result
	}

	#endif
}
