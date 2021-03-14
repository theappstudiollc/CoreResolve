//
//  Extensions-CoreLocation.swift
//  CoreResolve
//
//  Created by David Mitchell
//  Copyright © 2017 The App Studio LLC.
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

public extension CLLocationCoordinate2D {
	
	static func - (left: CLLocationCoordinate2D, right: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
		return CLLocationCoordinate2D(latitude: left.latitude - right.latitude, longitude: left.longitude - right.longitude)
	}
	
	static func + (left: CLLocationCoordinate2D, right: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
		return CLLocationCoordinate2D(latitude: left.latitude + right.latitude, longitude: left.longitude + right.longitude)
	}
	
	static func * (left: CLLocationCoordinate2D, right: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
		return CLLocationCoordinate2D(latitude: left.latitude * right.latitude, longitude: left.longitude * right.longitude)
	}
	
	static func * (left: CLLocationCoordinate2D, right: CLLocationDegrees) -> CLLocationCoordinate2D {
		return CLLocationCoordinate2D(latitude: left.latitude * right, longitude: left.longitude * right)
	}
	
	static func / (left: CLLocationCoordinate2D, right: CLLocationDegrees) -> CLLocationCoordinate2D {
		return CLLocationCoordinate2D(latitude: left.latitude / right, longitude: left.longitude / right)
	}
}

extension CLLocationCoordinate2D: Equatable, Hashable { // So that we can use CLLocationCoordinate2D as keys in a Dictionary
	
	public static func == (left: CLLocationCoordinate2D, right: CLLocationCoordinate2D) -> Bool {
		return left.latitude == right.latitude && left.longitude == right.longitude
	}
	
	public func hash(into hasher: inout Hasher) {
		hasher.combine(latitude)
		hasher.combine(longitude)
	}
}
