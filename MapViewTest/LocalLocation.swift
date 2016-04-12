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
    init (locationId: Int, latitude: Double, longitude: Double, vCount: Int)
    {
        self.locationId = locationId
        self.lat  = latitude
        self.long = longitude
        self.vehicleCount = vCount
    }
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
//            LocalLocation (locationId: 1, latitude: 42.3617552, longitude: -71.0599091, vCount: 1),
//            LocalLocation (locationId: 2, latitude: 42.3617562, longitude: -71.0599081, vCount: 2),
//            LocalLocation (locationId: 3, latitude: 42.3617572, longitude: -71.0599071, vCount: 3),
//            LocalLocation (locationId: 4, latitude: 42.3617582, longitude: -71.0599061, vCount: 4)
//
            LocalLocation (locationId: 96027, latitude: 42.3481, longitude: -71.0743, vCount: 2),
            LocalLocation (locationId: 96132, latitude: 42.3626, longitude: -71.0592, vCount: 17),
            LocalLocation (locationId: 95931, latitude: 42.3624, longitude: -71.0687, vCount: 3),
            LocalLocation (locationId: 96006, latitude: 42.3334, longitude: -71.1171, vCount: 0),
            LocalLocation (locationId: 96054, latitude: 42.3643, longitude: -71.0508, vCount: 1),
            LocalLocation (locationId: 96135, latitude: 40.7455, longitude: -74.0261, vCount: 0)
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
