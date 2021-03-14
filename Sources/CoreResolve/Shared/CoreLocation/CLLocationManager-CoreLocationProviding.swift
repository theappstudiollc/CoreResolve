//
//  CLLocationManager-CoreLocationProviding.swift
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
import ObjectiveC

// MARK: - Provides keys for Objective C Object Association
private struct CLLocationManagerCoreLocationProvidingAssociatedObjectKeys {
	static var delegate: UInt8 = 0
}

// MARK: - Adds CoreLocationProviding support to CLLocationManager
extension CLLocationManager: CoreLocationProviding {
	
	public weak var locationDelegate: CoreLocationProvidingDelegate? {
		get {
			// Return the proxy's delegate, if it is still around
			if let proxy = delegate as! CoreLocationProvidingDelegateProxy?, let value = proxy.delegate {
				return value
			}
			// The proxy lost its reference to the delegate -- let's induce a clean up before returning nil
			objc_setAssociatedObject(self, &CLLocationManagerCoreLocationProvidingAssociatedObjectKeys.delegate, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
			delegate = nil // The line above should allow delegate to nil out on its own eventually
			return nil
		}
		set {
			let proxy = CoreLocationProvidingDelegateProxy(newValue)
			objc_setAssociatedObject(self, &CLLocationManagerCoreLocationProvidingAssociatedObjectKeys.delegate, proxy, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
			delegate = proxy
		}
	}
	
	#if os(iOS) || os(macOS)
	
	public func startRangingBeacons(with constraint: CoreBeaconIdentityConstraint) {
		if #available(iOS 13.0, macOS 10.15, *) {
			startRangingBeacons(satisfying: constraint.identityConstraint)
		} else {
			#if !os(macOS)
			startRangingBeacons(in: constraint.region)
			#endif
		}
	}
	
	public func stopRangingBeacons(with constraint: CoreBeaconIdentityConstraint) {
		if #available(iOS 13.0, macOS 10.15, *) {
			stopRangingBeacons(satisfying: constraint.identityConstraint)
		} else {
			#if !os(macOS)
			stopRangingBeacons(in: constraint.region)
			#endif
		}
	}
	
	#endif
	
	// Implement static methods for macOS, tvOS, and watchOS so that more code can be shared
	#if os(tvOS) || os(watchOS)
	public static func isRangingAvailable() -> Bool { false }
	#endif
	
	// Implement static methods for tvOS and watchOS so that more code can be shared
	#if os(tvOS) || os(watchOS)
	public static func deferredLocationUpdatesAvailable() -> Bool { false }
	public static func isMonitoringAvailable(for regionClass: AnyClass) -> Bool { false }
	public static func significantLocationChangeMonitoringAvailable() -> Bool { false }
	#endif
	
	// Implement static methods for tvOS so that more code can be shared
	#if os(tvOS)
	public static func headingAvailable() -> Bool { false }
	#endif
}

// MARK: - Forwards CLLocationManagerDelegate calls to a CoreLocationProviding delegate
internal final class CoreLocationProvidingDelegateProxy: NSObject, CLLocationManagerDelegate {
	
	/// The delegate this proxy will forward CLLocationManagerDelegate calls to. Keep weak references only
	internal weak var delegate: CoreLocationProvidingDelegate?
	
	required init?(_ delegate: CoreLocationProvidingDelegate?) {
		guard let delegate = delegate else { return nil }
		self.delegate = delegate
		super.init()
	}
	
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		delegate?.locationProvider(manager, didChangeAuthorization: status)
	}

	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		delegate?.locationProvider(manager, didFailWithError: error as! CLError)
	}

	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard let locationDelegate = delegate as? CoreLocationLocationProvidingDelegate else { return }
		locationDelegate.locationProvider(manager, didUpdateLocations: locations)
	}
	
	#if os(iOS) || os(macOS)
	
	func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
		guard let regionDelegate = delegate as? CoreLocationRegionProvidingDelegate else { return }
		regionDelegate.locationProvider(manager, didDetermineState: state, for: region)
	}
	
	func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
		guard let regionDelegate = delegate as? CoreLocationRegionProvidingDelegate else { return }
		regionDelegate.locationProvider(manager, didEnterRegion: region)
	}
	
	func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
		guard let regionDelegate = delegate as? CoreLocationRegionProvidingDelegate else { return }
		regionDelegate.locationProvider(manager, didExitRegion: region)
	}
	
	func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
		guard let regionDelegate = delegate as? CoreLocationRegionProvidingDelegate else { return }
		regionDelegate.locationProvider(manager, monitoringDidFailFor: region, withError: error as! CLError)
	}
	
	func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
		guard let regionDelegate = delegate as? CoreLocationRegionProvidingDelegate else { return }
		regionDelegate.locationProvider(manager, didStartMonitoringFor: region)
	}
	
	func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
		guard let locationDelegate = delegate as? CoreLocationLocationProvidingDelegate else { return }
		locationDelegate.locationProvider(manager, didFinishDeferredUpdatesWithError: error as! CLError?)
	}
	
	#endif
	
	#if os(iOS) || os(macOS) || os(watchOS)
	
	func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
		guard let headingDelegate = delegate as? CoreLocationHeadingProvidingDelegate else { return }
		headingDelegate.locationProvider(manager, didUpdateHeading: newHeading)
	}
	
	func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
		guard let headingDelegate = delegate as? CoreLocationHeadingProvidingDelegate else { return false }
		return headingDelegate.locationProviderShouldDisplayHeadingCalibration(manager)
	}
	
	#endif
	
	#if os(iOS)
	
	func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
		guard let locationDelegate = delegate as? CoreLocationLocationProvidingDelegate else { return }
		locationDelegate.locationProviderDidPauseLocationUpdates(manager)
	}
	
	func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
		guard let locationDelegate = delegate as? CoreLocationLocationProvidingDelegate else { return }
		locationDelegate.locationProviderDidResumeLocationUpdates(manager)
	}
	
	@available(iOS 13.0, *)
	func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
		guard let beaconDelegate = delegate as? CoreLocationBeaconProvidingDelegate else { return }
		let constraint = CoreBeaconIdentityConstraint(constraint: beaconConstraint)
		beaconDelegate.locationProvider(manager, didRangeBeacons: beacons, with: constraint)
	}
	
	@available(iOS 13.0, *)
	func locationManager(_ manager: CLLocationManager, didFailRangingFor beaconConstraint: CLBeaconIdentityConstraint, error: Error) {
		guard let beaconDelegate = delegate as? CoreLocationBeaconProvidingDelegate else { return }
		let constraint = CoreBeaconIdentityConstraint(constraint: beaconConstraint)
		beaconDelegate.locationProvider(manager, rangingBeaconsDidFailFor: constraint, withError: error as! CLError)
	}
	
	#if !targetEnvironment(macCatalyst)
	
	func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
		guard let visitDelegate = delegate as? CoreLocationVisitProvidingDelegate else { return }
		visitDelegate.locationProvider(manager, didVisit: visit)
	}
	
	func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
		guard let beaconDelegate = delegate as? CoreLocationBeaconProvidingDelegate else { return }
		let constraint = CoreBeaconIdentityConstraint(region: region)
		beaconDelegate.locationProvider(manager, didRangeBeacons: beacons, with: constraint)
	}
	
	func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
		guard let beaconDelegate = delegate as? CoreLocationBeaconProvidingDelegate else { return }
		let constraint = CoreBeaconIdentityConstraint(region: region)
		beaconDelegate.locationProvider(manager, rangingBeaconsDidFailFor: constraint, withError: error as! CLError)
	}
	
	#endif
	
	#endif
}
