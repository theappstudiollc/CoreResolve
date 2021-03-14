//
//  MockCoreLocationProviding.swift
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

import CoreLocation
import CoreResolve

public class MockCoreLocationProviding {
	
	public init() { }

	// MARK: - Public properties
	
	public var desiredAccuracy: CLLocationAccuracy = 0
	public var distanceFilter: CLLocationDistance = 0
	
	// MARK: - Static handlers

	public static var authorizationStatusHandler = {
		return CLAuthorizationStatus.notDetermined
	}
	public static var headingAvailableHandler = {
		return true
	}
	public static var locationServicesEnabledHandler = {
		return true
	}
	
	// MARK: - Handlers
	
	public weak var locationDelegate: CoreLocationProvidingDelegate? {
		didSet { locationDelegateDidSetHandler?(locationDelegate) }
	}
	public var locationDelegateDidSetHandler: ((CoreLocationProvidingDelegate?) -> Void)?
	public var requestLocationHandler = { }
	public var stopUpdatingLocationHandler = { }
	
	#if os(iOS) || os(macOS) || os(watchOS)
	
	public static var deferredLocationUpdatesAvailableHandler = {
		return true
	}
	
	public static var isMonitoringAvailableHandler: ((_: AnyClass) -> Bool) = { regionClass in
		return true
	}
	
	public static var significantLocationChangeMonitoringAvailableHandler = {
		return true
	}
	
	public var activityType: CLActivityType = .other
	public var dismissHeadingCalibrationDisplayHandler = { }
	public var heading: CLHeading? = nil
	public var headingFilter: CLLocationDegrees = 0
	public var monitoredRegions: Set<CLRegion> = []
	public var pausesLocationUpdatesAutomatically: Bool = true
	public var requestStateHandler: ((_: CLRegion) -> Void) = { region in }
	public var startMonitoringHandler: ((_: CLRegion) -> Void) = { region in }
	public var startMonitoringSignificantLocationChangesHandler = { }
	public var startUpdatingHeadingHandler = { }
	public var startUpdatingLocationHandler = { }
	public var stopMonitoringHandler: ((_: CLRegion) -> Void) = { region in }
	public var stopMonitoringSignificantLocationChangesHandler = { }

	#endif

	#if os(iOS) || os(macOS)

	public var startRangingBeaconsHandler: ((_: NSObject) -> Void) = { constraint in }
	public var startRangingBeaconsHandlerLegacy: ((_: CLBeaconRegion) -> Void) = { region in }
	public var stopRangingBeaconsHandler: ((_: NSObject) -> Void) = { constraint in }
	public var stopRangingBeaconsHandlerLegacy: ((_: CLBeaconRegion) -> Void) = { region in }

	#endif

	#if os(iOS) || os(tvOS) || os(watchOS)
	
	public var requestWhenInUseAuthorizationHandler = { }
	
	#endif
	
	#if os(iOS) || os(watchOS)
	
	public static var isRangingAvailableHandler = {
		return true
	}
	
	public var allowsBackgroundLocationUpdates: Bool = true
	public var allowDeferredLocationUpdatesHandler: ((_: CLLocationDistance, _: TimeInterval) -> Void) = { distance, timeout in }
	public var disallowDeferredLocationUpdatesHandler = { }
	public var requestAlwaysAuthorizationHandler = { }
	public var startMonitoringVisitsHandler = { }
	public var stopMonitoringVisitsHandler = { }
	public var stopUpdatingHeadingHandler = { }
	public var showsBackgroundLocationIndicator: Bool = false

	#endif
}

extension MockCoreLocationProviding: CoreLocationProviding {

	public static func authorizationStatus() -> CLAuthorizationStatus {
		return authorizationStatusHandler()
	}
	
	public static func headingAvailable() -> Bool {
		return headingAvailableHandler()
	}
	
	public static func locationServicesEnabled() -> Bool {
		return locationServicesEnabledHandler()
	}
	
	public func requestLocation() {
		requestLocationHandler()
	}
	
	public func stopUpdatingLocation() {
		stopUpdatingLocationHandler()
	}
	
	#if os(iOS) || os(macOS) || os(watchOS)
	
	public static func deferredLocationUpdatesAvailable() -> Bool {
		return deferredLocationUpdatesAvailableHandler()
	}

	public func dismissHeadingCalibrationDisplay() {
		dismissHeadingCalibrationDisplayHandler()
	}

	public static func isMonitoringAvailable(for regionClass: AnyClass) -> Bool {
		return isMonitoringAvailableHandler(regionClass)
	}
	
	public static func significantLocationChangeMonitoringAvailable() -> Bool {
		return significantLocationChangeMonitoringAvailableHandler()
	}
	
	public func requestState(for region: CLRegion) {
		requestStateHandler(region)
	}
	
	public func startMonitoring(for region: CLRegion) {
		startMonitoringHandler(region)
	}
	
	public func startMonitoringSignificantLocationChanges() {
		startMonitoringSignificantLocationChangesHandler()
	}

	public func startUpdatingHeading() {
		startUpdatingHeadingHandler()
	}

	public func startUpdatingLocation() {
		startUpdatingLocationHandler()
	}

	public func stopMonitoring(for region: CLRegion) {
		stopMonitoringHandler(region)
	}
	
	public func stopMonitoringSignificantLocationChanges() {
		stopMonitoringSignificantLocationChangesHandler()
	}

	#endif

	#if os(iOS) || os(macOS)

	public func startRangingBeacons(with constraint: CoreBeaconIdentityConstraint) {
		if #available(iOS 13.0, macOS 10.15, *) {
			startRangingBeaconsHandler(constraint.identityConstraint)
		} else {
			startRangingBeaconsHandlerLegacy(constraint.region)
		}
	}

	public func stopRangingBeacons(with constraint: CoreBeaconIdentityConstraint) {
		if #available(iOS 13.0, macOS 10.15, *) {
			stopRangingBeaconsHandler(constraint.identityConstraint)
		} else {
			stopRangingBeaconsHandlerLegacy(constraint.region)
		}
	}

	#endif

	#if os(iOS) || os(tvOS) || os(watchOS)
	
	public func requestWhenInUseAuthorization() {
		requestWhenInUseAuthorizationHandler()
	}
	
	#endif
	
	#if os(iOS) || os(watchOS)
	
	public static func isRangingAvailable() -> Bool {
		return isRangingAvailableHandler()
	}
	
	public func allowDeferredLocationUpdates(untilTraveled distance: CLLocationDistance, timeout: TimeInterval) {
		allowDeferredLocationUpdatesHandler(distance, timeout)
	}
	
	public func disallowDeferredLocationUpdates() {
		disallowDeferredLocationUpdatesHandler()
	}

	public func requestAlwaysAuthorization() {
		requestAlwaysAuthorizationHandler()
	}
	
	public func startMonitoringVisits() {
		startMonitoringVisitsHandler()
	}

	public func stopMonitoringVisits() {
		stopMonitoringVisitsHandler()
	}

	public func stopUpdatingHeading() {
		stopUpdatingHeadingHandler()
	}
	
	#endif
	
	#if os(macOS)
	
	public static func isRangingAvailable() -> Bool { return false }

	#endif
	
	#if os(tvOS)
	
	public static func deferredLocationUpdatesAvailable() -> Bool { return false }
	public static func isMonitoringAvailable(for regionClass: AnyClass) -> Bool { return false }
	public static func isRangingAvailable() -> Bool { return false }
	public static func significantLocationChangeMonitoringAvailable() -> Bool { return false }
	
	#endif
}
