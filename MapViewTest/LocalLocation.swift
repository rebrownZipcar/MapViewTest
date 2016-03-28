//
//  LocalLocation.swift
//  zipcar
//
//  Created by Richard E. Brown on 3/22/16.
//  Copyright © 2016 Zipcar, Inc. All rights reserved.
//

import Foundation
import MapKit

enum LocalLocationError: ErrorType
{
    case NoLocationsInRange
}

/// This all temporary to serve as model.
struct LocalLocation
{
    var locationId : Int
    var lat : Double
    var long : Double
    var vehicleCount : Int

    init (locationId: Int, latitude: Double, longitude: Double, vCount: Int)
    {
        self.locationId = locationId
        self.lat  = latitude
        self.long = longitude
        self.vehicleCount = vCount
    }
}

struct LocalLocations
{
    static func getOneLocation (id: Int) -> LocalLocation?
    {
        if let location = database[ id ]
        {
            return location
        }
        return nil
    }

    let locations =
        [
            LocalLocation (locationId: 1, latitude: 42.3617552, longitude: -71.0599091, vCount: 1),
            LocalLocation (locationId: 2, latitude: 42.3617562, longitude: -71.0599081, vCount: 2),
            LocalLocation (locationId: 3, latitude: 42.3617572, longitude: -71.0599071, vCount: 3),
            LocalLocation (locationId: 4, latitude: 42.3617582, longitude: -71.0599061, vCount: 4)
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

    func getLocationsInRange (centerCoordinate: CLLocationCoordinate2D, radius: Double, locationIDs: [Int]?) throws -> [LocalLocation]
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

        return results
    }

    func locationCount () -> Int
    {
        return locations.count
    }

}
