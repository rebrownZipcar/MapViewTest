//
//  Location.swift
//  MapViewTest
//
//  Created by Richard E. Brown on 4/19/16.
//  Copyright © 2016 Zipcar. All rights reserved.
//

import Foundation
import CoreData
import MapKit

public let modelName = "location"
public let modelBundle = NSBundle(identifier: "com.zipcar.MapViewTest")!

struct InitLoc
{
    var lat : Double
    var long : Double
    var vehicleCount : Int16
}

public final class Location: NSManagedObject
{
    static public let entityName = "Location"

    @NSManaged var id: NSNumber?
    @NSManaged var latitude: NSNumber?
    @NSManaged var longitude: NSNumber?
    @NSManaged var vehicleCount: NSNumber?

    init (context: NSManagedObjectContext, id: Int32, latitude: Double, longitude: Double, vehicleCount: Int16)
    {
        let entity = NSEntityDescription.entityForName (Location.entityName, inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)

        self.id = NSNumber(int: id)
        self.latitude = latitude
        self.longitude = longitude
        self.vehicleCount = NSNumber(short: vehicleCount)
    }

    public class func newLocation (context: NSManagedObjectContext, id: Int32, latitude: Double, longitude: Double, vehicles: Int16 = -1) -> Location
    {
        return Location (context: context, id: id, latitude: latitude, longitude: longitude, vehicleCount: vehicles)
    }

    public class func setInitialLocations (context: NSManagedObjectContext)
    {
        let initialLocationData =
        [
            InitLoc (lat: 42.3481, long: -71.0743, vehicleCount: 2),
            InitLoc (lat: 42.3626, long: -71.0592, vehicleCount: 17),
            InitLoc (lat: 42.3624, long: -71.0687, vehicleCount: 3),
            InitLoc (lat: 42.3334, long: -71.1171, vehicleCount: 0),
            InitLoc (lat: 42.3643, long: -71.0508, vehicleCount: 1),
            InitLoc (lat: 40.7455, long: -74.0261, vehicleCount: 0)
        ]

        for loc in initialLocationData
        {
            Location.newLocation (context, id: Int32(getRandomNumber(1000000)), latitude: loc.lat, longitude: loc.long, vehicles: loc.vehicleCount)
        }
    }

    public class func initialLocationsExist (context: NSManagedObjectContext) throws
    {
        let request = NSFetchRequest(entityName: "Location")

        var results: [Location] = []

        do
        {
            if let fetchResults = try context.executeFetchRequest(request) as? [Location]
            {
                results = fetchResults
            }
        }
        catch{}

        guard results.count > 0 else
        {
            throw LocalLocationError.NoLocationsInRange
        }

        print("Search results count = \(results.count)")
    }

    public class func getLocationsInRange (context: NSManagedObjectContext, centerCoordinate: CLLocationCoordinate2D, radius: Double) throws -> [Location]
    {
        let request = NSFetchRequest(entityName: "Location")
        let resultPredicate1 = NSPredicate(format: "latitude >= %F", centerCoordinate.latitude - radius)
        let resultPredicate2 = NSPredicate(format: "latitude <= %F", centerCoordinate.latitude + radius)
        let resultPredicate3 = NSPredicate(format: "longitude >= %F", centerCoordinate.longitude - radius)
        let resultPredicate4 = NSPredicate(format: "longitude <= %F", centerCoordinate.longitude + radius)

        let predicate = NSCompoundPredicate(type: .AndPredicateType, subpredicates: [resultPredicate1, resultPredicate2, resultPredicate3, resultPredicate4])

        request.predicate = predicate
        var results: [Location] = []

        do
        {
            if let fetchResults = try context.executeFetchRequest(request) as? [Location]
            {
                results = fetchResults
            }
        }
        catch{}

        guard results.count > 0 else
        {
            throw LocalLocationError.NoLocationsInRange
        }

        print("Search results count = \(results.count)")
        return results
    }

    @objc private override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?)
    {
        super.init (entity: entity, insertIntoManagedObjectContext: context)
    }

    public class func getRandomNumber (upperBound: Int) -> Int
    {
        return Int(arc4random_uniform(UInt32(upperBound)))
    }
}
