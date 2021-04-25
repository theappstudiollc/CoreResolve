//
//  CoreLocationProvidingDelegate.swift
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

/// Handles events from the CoreLocationProviding instance
public protocol CoreLocationProvidingDelegate: AnyObject {
	
	/// Invoked when the authorization status changes for this application.
	///
	/// - Parameters:
	///   - provider: The CoreLocationProviding instance providing the status.
	///   - status: The new authorization status.
	func locationProvider(_ provider: CoreLocationProviding, didChangeAuthorization status: CLAuthorizationStatus)
	
	/// Invoked when an error has occurred.
	///
	/// - Parameters:
	///   - provider: The CoreLocationProviding instance providing the error.
	///   - error: The encountered error.
	func locationProvider(_ provider: CoreLocationProviding, didFailWithError error: CLError)
}

/// Handles location events from the CoreLocationProviding instance
public protocol CoreLocationLocationProvidingDelegate: CoreLocationProvidingDelegate {
	
	/// Invoked when new locations are available.
	///
	/// - Parameters:
	///   - provider: The CoreLocationProviding instance providing the locations.
	///   - locations: An array of CLLocation objects in chronological order.
	func locationProvider(_ provider: CoreLocationProviding, didUpdateLocations locations: [CLLocation])
	
	/// Invoked when location updates are automatically paused.
	///
	/// - Parameter provider: The CoreLocationProviding instance that has paused location updates.
	func locationProviderDidPauseLocationUpdates(_ provider: CoreLocationProviding)
	
	/// Invoked when location updates are automatically resumed.
	///
	/// - Parameter provider: The CoreLocationProviding instance that has resumed location updates.
	func locationProviderDidResumeLocationUpdates(_ provider: CoreLocationProviding)
	
	/// Invoked when deferred updates will no longer be delivered.
	///
	/// - Parameters:
	///   - provider: The CoreLocationProviding instance that has finished reporting deferred updates.
	///   - error: `nil` if updates are finished because the specified criterion were met, otherwise an Error describing the reason for ending updates.
	func locationProvider(_ provider: CoreLocationProviding, didFinishDeferredUpdatesWithError error: CLError?)
}

#if os(iOS) || os(macOS) || os(watchOS)

/// Handles heading events from the CoreLocationProviding instance
public protocol CoreLocationHeadingProvidingDelegate: CoreLocationProvidingDelegate {
	
	/// Invoked when a new heading is available.
	///
	/// - Parameters:
	///   - provider: The CoreLocationProviding instance providing the heading.
	///   - newHeading: The heading of the device.
	func locationProvider(_ provider: CoreLocationProviding, didUpdateHeading newHeading: CLHeading)
	
	/// Invoked when The CoreLocationProviding instance requests whether to present a heading calibration to the user.
	///
	/// - Parameter provider: The CoreLocationProviding instance requesting whether to presenting the calibration screen.
	/// - Returns: Returns whether a heading calibration screen should be displayed.
	func locationProviderShouldDisplayHeadingCalibration(_ provider: CoreLocationProviding) -> Bool
}

#endif

#if os(iOS) || os(macOS)

/// Handles region events from the CoreLocationProviding instance
public protocol CoreLocationRegionProvidingDelegate: CoreLocationProvidingDelegate {
	
	/// Invoked when there's a state transition for a monitored region or in response to a request for state via a call to requestStateForRegion:
	///
	/// - Parameters:
	///   - provider: The CoreLocationProviding instance providing the state for the region.
	///   - state: The current state of the CLRegion.
	///   - region: The region for which the state has been determined.
	func locationProvider(_ provider: CoreLocationProviding, didDetermineState state: CLRegionState, for region: CLRegion)
	
	/// Invoked when the user enters a monitored region.
	///
	/// - Parameters:
	///   - provider: The CoreLocationProviding instance monitoring the region.
	///   - region: The entered region.
	func locationProvider(_ provider: CoreLocationProviding, didEnterRegion region: CLRegion)
	
	/// Invoked when the user exits a monitored region.
	///
	/// - Parameters:
	///   - provider: The CoreLocationProviding instance monitoring the region.
	///   - region: The exited region.
	func locationProvider(_ provider: CoreLocationProviding, didExitRegion region: CLRegion)
	
	/// Invoked when a monitoring for a region started successfully.
	///
	/// - Parameters:
	///   - provider: The CoreLocationProviding instance monitoring the region.
	///   - region: The monitored region.
	func locationProvider(_ provider: CoreLocationProviding, didStartMonitoringFor region: CLRegion)
	
	/// Invoked when a region monitoring error has occurred.
	///
	/// - Parameters:
	///   - provider: The CoreLocationProviding instance providing the error.
	///   - region: The region for which the error occurred.
	///   - error: The encountered error.
	func locationProvider(_ provider: CoreLocationProviding, monitoringDidFailFor region: CLRegion?, withError error: CLError)
}

#endif

#if os(iOS)

/// Handles beacon events from the CoreLocationProviding instance
public protocol CoreLocationBeaconProvidingDelegate: CoreLocationRegionProvidingDelegate {
	
	/// Invoked when a new set of beacons are available in the specified region.
	///
	/// - Parameters:
	///   - provider: The CoreLocationProviding instance providing the beacons for the region.
	///   - beacons: The set of beacons available in the specified region.
	///   - constraint: The `CoreBeaconIdentityConstraint` containing the beacons.
	func locationProvider(_ provider: CoreLocationProviding, didRangeBeacons beacons: [CLBeacon], with constraint: CoreBeaconIdentityConstraint)
	
	/// Invoked when an error has occurred ranging beacons in a region.
	///
	/// - Parameters:
	///   - provider: The CoreLocationProviding instance providing the error for the region.
	///   - constraint: The `CoreBeaconIdentityConstraint` for which the error occurred.
	///   - error: The encountered error.
	func locationProvider(_ provider: CoreLocationProviding, rangingBeaconsDidFailFor constraint: CoreBeaconIdentityConstraint, withError error: CLError)
}

/// Handles visit events from the CoreLocationProviding instance (not called in macCatalyst)
public protocol CoreLocationVisitProvidingDelegate: CoreLocationProvidingDelegate {
	
	/// Invoked when the CLLocationManager determines that the device has visited a location.
	///
	/// - Parameters:
	///   - provider: The CoreLocationProviding instance providing the visit.
	///   - visit: The CLVisit object defining the currently known properties of the visit.
	func locationProvider(_ provider: CoreLocationProviding, didVisit visit: CLVisit)
}

#endif
