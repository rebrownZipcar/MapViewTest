//
//  Location.swift
//  MapViewTest
//
//  Created by Richard E. Brown on 4/19/16.
//  Copyright © 2016 Zipcar. All rights reserved.
//

import Foundation
import MagicalRecord
import MapKit


extension Location
{
    convenience init (id: Int32, latitude: Double, longitude: Double, vehicleCount: Int16)
    {
        self.init()
        
        self.id = NSNumber(int: id)
        self.latitude = latitude
        self.longitude = longitude
        self.vehicleCount = NSNumber(short: vehicleCount)
    }

    internal class func initialLocations () -> [Location]
    {
        let initialLocationData =
            [
                Location(id: Int32(getRandomNumber(1000000)), latitude: 42.3481, longitude: -71.0743, vehicleCount: 2),
                Location(id: Int32(getRandomNumber(1000000)), latitude: 42.3626, longitude: -71.0592, vehicleCount: 17),
                Location(id: Int32(getRandomNumber(1000000)), latitude: 42.3624, longitude: -71.0687, vehicleCount: 3),
                Location(id: Int32(getRandomNumber(1000000)), latitude: 42.3334, longitude: -71.1171, vehicleCount: 0),
                Location(id: Int32(getRandomNumber(1000000)), latitude: 42.3643, longitude: -71.0508, vehicleCount: 1),
                Location(id: Int32(getRandomNumber(1000000)), latitude: 40.7455, longitude: -74.0261, vehicleCount: 0)
        ]
        return initialLocationData
    }

    class func getLocationsInRange (centerCoordinate: CLLocationCoordinate2D, radius: Double) throws -> [Location]
//    class func getLocationsInRange (context: NSManagedObjectContext, centerCoordinate: CLLocationCoordinate2D, radius: Double) throws -> [Location]
    {
        let resultPredicate1 = NSPredicate(format: "latitude >= %F", centerCoordinate.latitude - radius)
        let resultPredicate2 = NSPredicate(format: "latitude <= %F", centerCoordinate.latitude + radius)
        let resultPredicate3 = NSPredicate(format: "longitude >= %F", centerCoordinate.longitude - radius)
        let resultPredicate4 = NSPredicate(format: "longitude <= %F", centerCoordinate.longitude + radius)

        let predicate = NSCompoundPredicate(type: .AndPredicateType, subpredicates: [resultPredicate1, resultPredicate2, resultPredicate3, resultPredicate4])
//        let request = NSFetchRequest(entityName: "Location")
        let request = Location.MR_requestAllWithPredicate(predicate)

//        request.predicate = predicate
//        var results: [Location] = []
        let results: [Location] = Location.MR_executeFetchRequest(request) as! [Location]

//        do
//        {
//            if let fetchResults = try context.executeFetchRequest(request) as? [Location]
//            {
//                results = fetchResults
//            }
//        }
//        catch{}

        guard results.count > 0 else
        {
            throw LocalLocationError.NoLocationsInRange
        }

        print("Search results count = \(results.count)")
        return results
    }

    class func getRandomNumber (upperBound: Int) -> Int
    {
        return Int(arc4random_uniform(UInt32(upperBound)))
    }
}
