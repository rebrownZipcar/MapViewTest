//
//  SearchLocationModel.swift
//  MapViewTest
//
//  Created by Richard E. Brown on 4/20/16.
//  Copyright © 2016 Zipcar. All rights reserved.
//

import Foundation
import UIKit
import MapKit

enum LocationIcon: String
{
    case None = ""
    case Pin = "pinLocation"
    case GPin = "pinGMapLocation"
    case Home = "homeLocation"
    case Airport = "airportLocation"
}

struct SearchLocation: Equatable
{
    let locationName: String
    let address: String
    let machineAddress: CLLocationCoordinate2D
    var lastUsed: NSDate
    let icon: LocationIcon
}

func ==(lhs: SearchLocation, rhs: SearchLocation) -> Bool
{
    return lhs.address == rhs.address &&
        lhs.machineAddress == rhs.machineAddress &&
        lhs.lastUsed == rhs.lastUsed
}


struct SearchLocationResults
{
    var results: [SearchLocation]

    init ()
    {
        results = [SearchLocation]()
    }

    subscript(index: Int) -> SearchLocation
    {
        get
        {
            return self.results[index]
        }
    }

//    func getDistanceIndex (distance: Int) -> Int
//    {
//        var index = 0
//
//        for _ in self.results
//        {
//            if distance < self.results[index].distance
//            {
//                break
//            }
//            index += 1
//        }
//
//        return index
//    }

//    mutating func insert (newElement: SearchLocation)
//    {
//        self.results.insert(newElement, atIndex: getDistanceIndex(newElement.distance))
//    }

    func count () -> Int
    {
        return self.results.count
    }

    mutating func removeAll (keepCapacity: Bool)
    {
        self.results.removeAll(keepCapacity: keepCapacity)
    }
}


struct LocationAddressConstants
{
    static let usa = "United States"
}

struct LocationAddress
{
    var placeName = ""
    var streetNum = ""
    var street = ""
    var city = ""
    var state = ""
    var country = ""

    init (place: CLPlacemark, inCountry: String)
    {
        // U.S. exceptionalism results.
        let currCountry = (inCountry == "" ? LocationAddressConstants.usa : inCountry)

        if let theName = place.name
        {
            placeName = theName
        }

        if let theStreetNum = place.subThoroughfare
        {
            streetNum = "\(theStreetNum) "
        }

        if let theStreet = place.thoroughfare
        {
            street = streetNum.isEmpty ? theStreet : "\(streetNum)\(theStreet)"
        }

        if let theCity = place.locality
        {
            city = street.isEmpty || (placeName == "\(street)") ? "\(theCity)" :", \(theCity)"
        }

        if let theState = place.administrativeArea
        {
            state = city.isEmpty ? "\(theState)" :", \(theState)"
        }

        if let theCountry = place.country
        {
            if theCountry != "" &&  theCountry != currCountry
            {
                self.country = state.isEmpty ? "\(theCountry)" :", \(theCountry)"
            }
        }

        /* UX says to display no country
         if let theCountry = place.country
         {
         if theCountry != "" &&  inCountry != theCountry
         {
         self.country = state.isEmpty ? "\(theCountry)" :", \(theCountry)"
         }
         }*/
    }

    func getAddress () -> String
    {
        if placeName == "\(street)"
        {
            return "\(city)\(state)\(country)"
        }
        return "\(street)\(city)\(state)\(country)"
    }
}
