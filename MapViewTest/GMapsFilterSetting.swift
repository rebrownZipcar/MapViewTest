//
//  GMapsFilterSetting.swift
//  MapViewTest
//
//  Created by Richard E. Brown on 5/3/16.
//  Copyright © 2016 Zipcar. All rights reserved.
//

import Foundation
import GoogleMaps

class GMapsFilterSetting: NSUserDefaults
{
    struct filterConstants
    {
        static let geocode = "geocode"
        static let address = "address"
        static let establishment = "establishment"
        static let region = "region"
        static let city = "city"
    }

    let registrationDict = [filterConstants.geocode: false,
                            filterConstants.address: false,
                            filterConstants.establishment: false,
                            filterConstants.region: false,
                            filterConstants.city: false]


    let defaults = NSUserDefaults.standardUserDefaults()

    var geocodeFilter: Bool
    {
        set
        {
            defaults.setBool(newValue, forKey: filterConstants.geocode)
        }

        get
        {
            if let hasDefault: Bool? = defaults.boolForKey(filterConstants.geocode)
            {
                return hasDefault!
            }

            defaults.setBool(false, forKey: filterConstants.geocode)
            return false
        }
    }

    var addressFilter: Bool
        {
        set
        {
            defaults.setBool(newValue, forKey: filterConstants.address)
        }

        get
        {
            if let hasDefault: Bool? = defaults.boolForKey(filterConstants.address)
            {
                return hasDefault!
            }

            defaults.setBool(false, forKey: filterConstants.address)
            return false
        }
    }

    var establishmentFilter: Bool
        {
        set
        {
            defaults.setBool(newValue, forKey: filterConstants.establishment)
        }

        get
        {
            if let hasDefault: Bool? = defaults.boolForKey(filterConstants.establishment)
            {
                return hasDefault!
            }

            defaults.setBool(false, forKey: filterConstants.establishment)
            return false
        }
    }

    var regionFilter: Bool
        {
        set
        {
            defaults.setBool(newValue, forKey: filterConstants.region)
        }

        get
        {
            if let hasDefault: Bool? = defaults.boolForKey(filterConstants.region)
            {
                return hasDefault!
            }

            defaults.setBool(false, forKey: filterConstants.region)
            return false
        }
    }

    var cityFilter: Bool
        {
        set
        {
            defaults.setBool(newValue, forKey: filterConstants.city)
        }

        get
        {
            if let hasDefault: Bool? = defaults.boolForKey(filterConstants.city)
            {
                return hasDefault!
            }

            defaults.setBool(false, forKey: filterConstants.city)
            return false
        }
    }

    func currentFilter () -> GMSPlacesAutocompleteTypeFilter
    {
        var currFilter: GMSPlacesAutocompleteTypeFilter = .NoFilter

        if geocodeFilter
        {
            currFilter = .Geocode
        }
        else if addressFilter
        {
            currFilter = .Address
        }
        else if establishmentFilter
        {
            currFilter = .Establishment
        }
        else if regionFilter
        {
            currFilter = .Region
        }
        else if cityFilter
        {
            currFilter = .City
        }

        return currFilter
    }
}
