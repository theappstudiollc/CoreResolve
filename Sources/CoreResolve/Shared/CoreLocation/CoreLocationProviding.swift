//
//  CoreLocationProviding.swift
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

#if targetEnvironment(macCatalyst)

public protocol CoreLocationProviding: CoreBeaconRanging, CoreLocationCoordinateProviding, CoreLocationHeadingProviding, CoreLocationMonitoring, CoreLocationRegionMonitoring, CoreLocationVisitMonitoring { }

#elseif os(iOS)

public protocol CoreLocationProviding: CoreBeaconRanging, CoreLocationCoordinateProviding, CoreLocationDeferredUpdatesProviding, CoreLocationHeadingProviding, CoreLocationMonitoring, CoreLocationRegionMonitoring, CoreLocationVisitMonitoring { }

#elseif os(tvOS)

public protocol CoreLocationProviding: CoreLocationCoordinateProviding { }

#elseif os(watchOS)

public protocol CoreLocationProviding: CoreLocationCoordinateProviding, CoreLocationHeadingProviding, CoreLocationMonitoring { }

#elseif os(macOS)

public protocol CoreLocationProviding: CoreBeaconRanging, CoreLocationCoordinateProviding, CoreLocationHeadingProviding, CoreLocationMonitoring, CoreLocationRegionMonitoring { }

#endif

/// Provides CoreLocation services (i.e. a testable set of CLLocationManager capability)
public protocol CoreLocationCoordinateProviding: class {
	
	/// Determines the current authorization status of the calling application.
	///
	/// - Returns: Returns the current authorization status of the calling application.
	static func authorizationStatus() -> CLAuthorizationStatus
	
	/// Determines whether the user has location services enabled.
	///
	/// - Returns: Returns whether the user has location services enabled.
	static func locationServicesEnabled() -> Bool
	
	/// The desired location accuracy in meters.
	var desiredAccuracy: CLLocationAccuracy { get set }
	
	/// Specifies the minimum update distance in meters.
	var distanceFilter: CLLocationDistance { get set }
	
	/// The delegate implementing CoreLocationProvidingDelegate
	var locationDelegate: CoreLocationProvidingDelegate? { get set }
	
	/// Requests a single location update, which will inform the `locationDelegate`
	@available(iOS 9.3, macOS 10.14, tvOS 10.0, watchOS 2.2, *)
	func requestLocation()
	
	/// Stops updating locations (not sure why all platforms support this).
	func stopUpdatingLocation()
	
	/// Determines if the device supports deferred location updates.
	///
	/// - Returns: Returns YES if the device supports deferred location updates, otherwise NO.
	static func deferredLocationUpdatesAvailable() -> Bool
	
	/// Determines whether the device supports monitoring for the specified type of region.
	///
	/// - Parameter regionClass: The type of region requested.
	/// - Returns: Returns whether the device supports monitoring for the specified type of region.
	static func isMonitoringAvailable(for regionClass: AnyClass) -> Bool
	
	/// Determines whether the device supports ranging.
	///
	/// - Returns: Returns whether the device supports ranging.
	@available(macOS 10.15, *)
	static func isRangingAvailable() -> Bool

	/// Determines if the device supports significant location change monitoring.
	///
	/// - Returns: Returns YES if the device supports significant location change monitoring, otherwise NO.
	static func significantLocationChangeMonitoringAvailable() -> Bool
	
	/// Determines if the device supports the heading service, otherwise NO.
	///
	/// - Returns: Returns YES if the device supports the heading service, otherwise NO.
	static func headingAvailable() -> Bool
	
	#if os(iOS) || os(tvOS) || os(watchOS)
	
	/// Requests "when in use" location authorization from the user, if not already prompted
	func requestWhenInUseAuthorization()
	
	#endif

	#if os(iOS) || os(macOS) || os(watchOS)

	/// The type of user activity.
	@available(macOS 10.15, watchOS 4.0, *)
	var activityType: CLActivityType { get set }

	#endif
	
	#if os(iOS) || os(watchOS)

	/// Set to `true` when background location updates are desired.
	/// (this is in combination with UIBackgroundModes = 'location' in the Info.plist)
	@available(iOS 9.0, watchOS 4.0, *)
	var allowsBackgroundLocationUpdates: Bool { get set }
	
	/// Requests "always" location authorization from the user, if not already prompted
	func requestAlwaysAuthorization()
	
	#endif
	
	#if os(iOS) || os(macOS)
	
	/// Specifies that location updates may automatically be paused when possible.
	@available(macOS 10.15, *)
	var pausesLocationUpdatesAutomatically: Bool { get set }

	#endif

	#if os(iOS)
	
	/// Specifies that an indicator be shown when the app makes use of continuous background location updates.
	@available(iOS 11.0, *)
	var showsBackgroundLocationIndicator: Bool { get set }
	
	#endif
}

public protocol CoreLocationDeferredUpdatesProviding {
	
	/// Indicate that the application will allow the location manager to defer location updates until an exit criterion is met.
	///
	/// - Parameters:
	///   - distance: The distance threshold for which to resume providing location updates, or CLLocationDistanceMax
	///   - timeout: The timeout threshold for which to resume providing location updates, or CLTimeIntervalMax
	func allowDeferredLocationUpdates(untilTraveled distance: CLLocationDistance, timeout: TimeInterval)
	
	/// Disallows deferred location updates if previously enabled.
	func disallowDeferredLocationUpdates()
}

public protocol CoreLocationHeadingProviding: class {
	
	/// Dismisses the heading calibration immediately.
	@available(macOS 10.15, *)
	func dismissHeadingCalibrationDisplay()
	
	#if !os(tvOS) // `CLHeading` is not even defined on tvOS
	/// The latest heading update received, or nil if none is available.
	@available(macOS 10.15, *)
	var heading: CLHeading? { get }
	#endif
	
	/// The minimum amount of change in degrees needed for a heading service update.
	@available(macOS 10.15, *)
	var headingFilter: CLLocationDegrees { get set }
	
	/// Starts updating heading, which will inform the `locationDelegate`
	@available(macOS 10.15, *)
	func startUpdatingHeading()
	
	/// Stops updating heading, which will inform the `locationDelegate`
	#if !os(macOS)
	func stopUpdatingHeading()
	#endif
}

public protocol CoreLocationMonitoring {
	
	/// Starts updating locations, which will inform the `locationDelegate`
	@available(watchOS 3.0, *)
	func startUpdatingLocation()
}

public protocol CoreLocationRegionMonitoring: class {
	
	/// Asynchronously retrieves the cached state of the specified region.
	///
	/// - Parameter region: The region for which to request the state.
	func requestState(for region: CLRegion)
	
	/// A set of objects for the regions that are currently being monitored.
	var monitoredRegions: Set<CLRegion> { get }
	
	/// Starts monitoring the specified region.
	///
	/// - Parameter region: The region to start monitoring.
	func startMonitoring(for region: CLRegion)
	
	/// Starts monitoring significant location changes.
	func startMonitoringSignificantLocationChanges()
	
	/// Stops monitoring the specified region.
	///
	/// - Parameter region: The region to stop monitoring.
	func stopMonitoring(for region: CLRegion)
	
	/// Stops monitoring significant location changes.
	func stopMonitoringSignificantLocationChanges()
}

public protocol CoreLocationVisitMonitoring {
	
	/// Begin monitoring for visits.
	func startMonitoringVisits()
	
	/// Stop monitoring for visits.
	func stopMonitoringVisits()
}
