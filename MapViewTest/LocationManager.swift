//
//  LocationManager.swift
//  zipcar
//
//  Created by David Ferrero on 3/15/16.
//  Copyright © 2016 Zipcar, Inc. All rights reserved.
//

import UIKit
import CoreLocation

/// LocationManager is a singleton that wraps CLLocationManager functionality for purposes of centralizing all location authorization activities,
/// as well as handling distribution of location updates.
@objc public class LocationManager: NSObject, CLLocationManagerDelegate
{
    /// The singleton instance of LocationManager
    public static let sharedInstance = LocationManager()

    private let coreLocationManager = CLLocationManager()

    private override init()
    {
        desiredAccuracy = kCLLocationAccuracyKilometer
        distanceFilter = kCLDistanceFilterNone
        super.init()
        coreLocationManager.delegate = self
    }

    private var canPromptForLocation: Bool
    {
        return locationServicesEnabled && authorizationStatus == .NotDetermined
    }

    private func authorizationRequestDescription(authorizationRequested: CLAuthorizationStatus) -> String?
    {
        var requestDescription: String?

        if let infoPlist = NSBundle.mainBundle().infoDictionary
        {
            switch authorizationRequested
            {
            case .AuthorizedWhenInUse:
                requestDescription = infoPlist["NSLocationWhenInUseUsageDescription"] as? String
                break
            case .AuthorizedAlways:
                requestDescription = infoPlist["NSLocationAlwaysUsageDescription"] as? String
                break
            default:
                break
            }
        }

        return requestDescription
    }

    /// -Returns: true if location services are enabled and user has granted authorization to use location
    public var areLocationUpdatesPermissible: Bool
    {
        areLocationUpdatesPermissibleCalled = true

        return locationServicesEnabled && (authorizationStatus == .AuthorizedWhenInUse || authorizationStatus == .AuthorizedAlways)
    }

    /// Unit Test Use Only. Reset to nil in unit test setUp
    var areLocationUpdatesPermissibleCalled: Bool?


    /// Prompt the user for permission to observe their location according to the authorizationRequested.
    /// iOS will prompt the user for permission iff preconditions including if location services have been enabled,
    /// authorization status is Not Determined, and the required Info.plist entry for prompting for authorization is present.
    ///
    /// - Parameter authorizationRequested: the requested authorization (AuthorizedWhenInUse or AuthorizedAlways)
    /// - Returns: true if iOS will prompt for permission, or false if preconditions for prompting are not met
    public func promptForLocationAuthorization(authorizationRequested: CLAuthorizationStatus) -> Bool
    {
        promptForLocationAuthorizationCalled = true

        let willPrompt = canPromptForLocation && authorizationRequestDescription(authorizationRequested) != nil

        if willPrompt
        {
            switch authorizationRequested
            {
            case .AuthorizedAlways:
                coreLocationManager.requestAlwaysAuthorization()
                break
            case .AuthorizedWhenInUse:
                coreLocationManager.requestWhenInUseAuthorization()
                break
            default:
                return false
            }
        }

        return willPrompt
    }

    /// Unit Test Use Only. Reset to nil in unit test setUp
    var promptForLocationAuthorizationCalled: Bool?

    /// The last known location of the user or nil if no location is available. Location may
    /// not be available if location authorization has not been granted, or has been denied,
    /// or if startUpdatingLocation() has not be called. Returns immediately.
    ///
    /// - Returns: last known location or nil if no location is available.
    public func lastKnownLocation() -> CLLocation?
    {
        lastKnownLocationCalled = true

        return _lastKnownLocation
    }

    /// Unit Test Use Only. Reset to nil in unit test setUp
    var lastKnownLocationCalled: Bool?


    private var _lastKnownLocation: CLLocation?

    /// The CLLocationAccuracy for the wrapped CLLocationManager to use
    ///
    /// - Returns: the CLLocationAccuracy used by the wrapped CLLocationManager
    public var desiredAccuracy: CLLocationAccuracy
    {
        didSet {
//            DDLogSwift.logDebug("desiredAccuracy = \(desiredAccuracy)")
            coreLocationManager.desiredAccuracy = desiredAccuracy
        }
    }

    /// The CLLocationDistance for the wrapped CLLocationManager to use
    ///
    /// - Returns: the CLLocationDistance used by the wrapped CLLocationManager
    public var distanceFilter: CLLocationDistance
    {
        didSet {
//            DDLogSwift.logDebug("distanceFilter = \(distanceFilter)")
            coreLocationManager.distanceFilter = distanceFilter
        }
    }

    /// - Returns: the two letter NSLocaleCountryCode for the given user at this moment in time (e.g: "US")
    public var currentCountryCode: NSString?
    {
        let countryCode = NSLocale.currentLocale().objectForKey(NSLocaleCountryCode) as? String
//        DDLogSwift.logDebug("currentCountryCode = \(countryCode)")
        return countryCode
    }

    /// - Returns: the current CLAuthorizationStatus
    public var authorizationStatus: CLAuthorizationStatus
    {
//        DDLogSwift.logDebug("authorizationStatus = \(CLLocationManager.authorizationStatus())")
        return CLLocationManager.authorizationStatus()
    }

    /// - Returns: true if the user has enabled locationServices on this device, false otherwise.
    public var locationServicesEnabled: Bool
    {
//        DDLogSwift.logDebug("locationServicesEnabled = \(CLLocationManager.locationServicesEnabled())")
        return CLLocationManager.locationServicesEnabled()
    }

    /// Request that location updates be made available if preconditions are met.
    /// Preconditions include if location services have been enabled, and if authorization for location updates have been granted to this app.
    /// The first time this method is called successfully, it may take several seconds before location updates start to be observed and before
    /// lastKnownLocation is non-nil.
    ///
    /// - Returns: true if preconditions for location services have been met and location updates should be expected. Return false otherwise.
    public func startUpdatingLocation() -> Bool
    {
        startUpdatingLocationCalled = true

        let willStartUpdatingLocation = locationServicesEnabled &&
            (authorizationStatus == .AuthorizedWhenInUse || authorizationStatus == .AuthorizedAlways)

        if willStartUpdatingLocation
        {
            coreLocationManager.startUpdatingLocation()
        }

//        DDLogSwift.logDebug("startUpdatingLocation -> \(willStartUpdatingLocation)")
        return willStartUpdatingLocation
    }

    /// Unit Test Use Only. Reset to nil in unit test setUp
    var startUpdatingLocationCalled: Bool?

    /// Request that location updates cease if preconditions have been met.
    /// Preconditions include if location services have been enabled, and if authorization for location updates have been granted to this app.
    /// Note: It is possible that in-flight location updates may still be sent even after this method is called.
    ///
    /// - Returns: true if preconditions for location services have been met and location updates should cease. Return false otherwise.
    public func stopUpdatingLocation() -> Bool
    {
        stopUpdatingLocationCalled = true

        let willStopUpdatingLocation = locationServicesEnabled &&
            (authorizationStatus == .AuthorizedWhenInUse || authorizationStatus == .AuthorizedAlways)

        if willStopUpdatingLocation
        {
            coreLocationManager.stopUpdatingLocation()
        }

//        DDLogSwift.logDebug("stopUpdatingLocation -> \(willStopUpdatingLocation)")
        return willStopUpdatingLocation
    }

    /// Unit Test Use Only. Reset to nil in unit test setUp
    var stopUpdatingLocationCalled: Bool?

    // MARK: - CLLocationManageDelegate -

    /// If startUpdatingLocation() has been called and returns true, iOS will send location updates to the app through this
    /// CLLocationManageDelegate method. This method posts NSNotifications for NotificationName.LocationUpdated from the
    /// sharedInstance object so observers may register for location updates by adding observers for this NotificationName
    /// and sharedInstance. The sharedInstance will be the sender object while the userInfo Dictionary will contain a
    /// key = "location" and value = the last known CLLocation
    public func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
//        DDLogSwift.logDebug("locationManager(\(manager), didUpdateLocations: \(locations.last)")
        _lastKnownLocation = locations.last

        if let location = _lastKnownLocation
        {
            let userInfo: [NSObject : AnyObject] = ["location": location]
            NSNotificationCenter.defaultCenter().postNotificationName("kLocationUpdated", object: self, userInfo: userInfo)
        }
    }


    public func locationManager(manager: CLLocationManager, didFailWithError error: NSError)
    {
//        DDLogSwift.logError("locationManager(\(manager), didFailWithError: \(error.localizedDescription)")
    }

    /// A CLLocationManageDelegate method to centralize handling of CLAuthorizationStatus changes. If Restricted or
    /// Denied CLAuthorizationStatus is observed, stopUpdatingLocation() will be called and lastKnownLocation will be
    /// reset to nil. If AuthorizedWhenInUse or AuthorizedAlways is observed, startUpdatingLocation() will be called.
    /// If NotDetermined is called, no action will be taken.
    public func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus)
    {
//        DDLogSwift.logDebug("locationManager(\(manager), didChangeAuthorizationStatus: \(status)")

        switch status
        {
            // User has not yet made a choice with regards to this application
        case .NotDetermined:
            break

            // This application is not authorized to use location services.  Due
            // to active restrictions on location services, the user cannot change
            // this status, and may not have personally denied authorization
        case .Restricted:
            _lastKnownLocation = nil
            coreLocationManager.stopUpdatingLocation()
            break

            // User has explicitly denied authorization for this application, or
            // location services are disabled in Settings.
        case .Denied:
            _lastKnownLocation = nil
            coreLocationManager.stopUpdatingLocation()
            break

            // User has granted authorization to use their location at any time,
            // including monitoring for regions, visits, or significant location changes.
        case .AuthorizedAlways:
            startUpdatingLocation()
            break

            // User has granted authorization to use their location only when your app
            // is visible to them (it will be made visible to them if you continue to
            // receive location updates while in the background).  Authorization to use
            // launch APIs has not been granted.
        case .AuthorizedWhenInUse:
            startUpdatingLocation()
            break
        }
    }
}
