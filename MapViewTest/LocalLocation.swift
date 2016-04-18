//
//  LocalLocation.swift
//  zipcar
//
//  Created by Richard E. Brown on 3/22/16.
//  Copyright © 2016 Zipcar, Inc. All rights reserved.
//

import Foundation
import MapKit

extension NSDate
{
    private class func minuteInSeconds() -> Double { return 60 }
    private class func dayInSeconds() -> Double { return 86400 }
    private class func weekInSeconds() -> Double { return 604800 }

    func dateByAddingMinutes (minutesToAdd: Int) -> NSDate
    {
        let interval: NSTimeInterval = self.timeIntervalSinceReferenceDate + NSDate.minuteInSeconds() * Double(minutesToAdd)

        return NSDate (timeIntervalSinceReferenceDate: interval)
    }
}


enum LocalLocationError: ErrorType
{
    case NoLocationsInRange
}


enum LocalLocationUsageTypes
{
    case RoundTrip
    case OneWay
    case Floating
    case Unified
}

/// This all temporary to serve as model.
struct LocalLocation
{
    var locationId : Int
    var lat : Double
    var long : Double
    var vehicleCount : Int
/*
     var distance = 0.0
     var name: String               // description/address?
     var vehicles: [LocalVehicle] = []
     var address = ""                // for callout
        // pooling location fields
     var leadTime: Double = 0.0
     var minLength: Double = 0.0
     var alwaysOpen: Bool = false
*/
}

// Singleton

class LocalLocations
{
    static let sharedInstance = LocalLocations()
    private init () {}

    var startTime = NSDate()
    var endTime = NSDate().dateByAddingMinutes (120)
    
    static func getOneLocation (id: Int) -> LocalLocation?
    {
        if let location = database[ id ]
        {
            return location
        }
        return nil
    }

        // This would be populated normally as the result of a server call.
    private let locations =
        [
            LocalLocation (locationId: 96027, lat: 42.3481, long: -71.0743, vehicleCount: 2),
            LocalLocation (locationId: 96132, lat: 42.3626, long: -71.0592, vehicleCount: 17),
            LocalLocation (locationId: 95931, lat: 42.3624, long: -71.0687, vehicleCount: 3),
            LocalLocation (locationId: 96006, lat: 42.3334, long: -71.1171, vehicleCount: 0),
            LocalLocation (locationId: 96054, lat: 42.3643, long: -71.0508, vehicleCount: 1),
            LocalLocation (locationId: 96135, lat: 40.7455, long: -74.0261, vehicleCount: 0)
        ]

    private static let database : Dictionary<Int, LocalLocation> =
        {
            var theDatabase = Dictionary<Int, LocalLocation>()

            for loc in LocalLocations().locations
            {
                theDatabase[ loc.locationId as Int ] = loc
            }
            return theDatabase
    }()

    func populateLocations (centerCoordinate: CLLocationCoordinate2D, usageType: LocalLocationUsageTypes = .Unified)
    {
        /// Async API call here. Needs progress HUD. Or in caller.

        /// Determine max distance to set/return radius?
    }

    func getLocationsInRange (centerCoordinate: CLLocationCoordinate2D, radius: Double) throws -> [LocalLocation]
    {
        let results = locations.filter {
            (location: LocalLocation) -> Bool in
            return (location.lat >= (centerCoordinate.latitude - radius)) &&
                    (location.lat <= (centerCoordinate.latitude + radius)) &&
                    (location.long >= (centerCoordinate.longitude - radius)) &&
                    (location.long <= (centerCoordinate.longitude + radius))
        }

        guard results.count > 0 else
        {
            throw LocalLocationError.NoLocationsInRange
        }

        print("Search results count = \(results.count)")
        return results
    }

    func locationCount () -> Int
    {
        return locations.count
    }
}

class LocationService
{
    func getLocations (completion: ([LocalLocation])-> Void)
    {

    }
}
