//
//  DataHelper.swift
//  MapViewTest
//
//  Created by Richard E. Brown on 5/6/16.
//  Copyright © 2016 Zipcar. All rights reserved.
//

import Foundation
import UIKit
import MagicalRecord

protocol DataHelperProtocol
{
    associatedtype T

    static func count () -> Int
    static func preload (items: [T])
    static func insert (item: T)
//    static func delete (item: T) throws -> Void
//    static func findAll () throws -> [T]?
}

class LocationHelper: DataHelperProtocol
{
    typealias T = Location
    
    static func count () -> Int
    {
        return Int(Location.MR_countOfEntities())
    }

    static func preload (items: [T])
    {
        for item in items
        {
            insert (item)
        }
    }

    static func insert (item: T)
    {
        let newItem = Location.MR_createEntity()! as Location
        newItem.id = item.id
        newItem.latitude = item.latitude
        newItem.longitude = item.longitude
        newItem.vehicleCount = item.vehicleCount
    }

//    static func findAll () throws -> [T]?

}