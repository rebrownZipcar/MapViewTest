//
//  AppDefaults.swift
//  MapViewTest
//
//  Created by Richard E. Brown on 4/7/16.
//  Copyright © 2016 Zipcar. All rights reserved.
//

import Foundation

class AppDefaults : NSUserDefaults
{
    struct attributeConstants
    {
        static let tripsButtons = "tripsButtons"
        static let toolBarFilter = "toolBarFilter"
        static let locationButton = "locationButton"
        static let locationSearchBar = "locationSearchBar"
        static let locateMe = "locateMe"
        static let addLocations = "addLocations"
        static let hasInitedLocations = "initedLocations"
        static let enableAppleMaps = "useAppleMaps"
        static let enableGoogleMaps = "useGoogleMaps"
    }

    let registrationDict = [attributeConstants.tripsButtons: false,
                            attributeConstants.toolBarFilter: false,
                            attributeConstants.locationButton: true,
                            attributeConstants.locationSearchBar: false,
                            attributeConstants.locateMe: false,
                            attributeConstants.addLocations: false,
                            attributeConstants.hasInitedLocations: true,
                            attributeConstants.enableAppleMaps: true,
                            attributeConstants.enableGoogleMaps: false]


    let defaults = NSUserDefaults.standardUserDefaults()

    var tripsButtons: Bool
    {
        set
        {
            defaults.setBool(newValue, forKey: attributeConstants.tripsButtons)
        }

        get
        {
            if let hasDefault: Bool? = defaults.boolForKey(attributeConstants.tripsButtons)
            {
                return hasDefault!
            }

            defaults.setBool(false, forKey: attributeConstants.tripsButtons)
            return false
        }
    }

    var toolBarFilter: Bool
    {
        set
        {
            defaults.setBool(newValue, forKey: attributeConstants.toolBarFilter)
        }

        get
        {
            if let hasDefault: Bool? = defaults.boolForKey(attributeConstants.toolBarFilter)
            {
                return hasDefault!
            }

            defaults.setBool(false, forKey: attributeConstants.toolBarFilter)
            return false
        }
    }

    var locationButton: Bool
    {
        set
        {
            defaults.setBool(newValue, forKey: attributeConstants.locationButton)
        }

        get
        {
            if let hasDefault: Bool? = defaults.boolForKey(attributeConstants.locationButton)
            {
                return hasDefault!
            }

            defaults.setBool(true, forKey: attributeConstants.locationButton)
            return false
        }
    }

    var locationSearchBar: Bool
    {
        set
        {
            defaults.setBool(newValue, forKey: attributeConstants.locationSearchBar)
        }

        get
        {
            if let hasDefault: Bool? = defaults.boolForKey(attributeConstants.locationSearchBar)
            {
                return hasDefault!
            }

            defaults.setBool(false, forKey: attributeConstants.locationSearchBar)
            return false
        }
    }

    var locateMe: Bool
    {
        set
        {
            defaults.setBool(newValue, forKey: attributeConstants.locateMe)
        }

        get
        {
            if let hasDefault: Bool? = defaults.boolForKey(attributeConstants.locateMe)
            {
                return hasDefault!
            }

            defaults.setBool(true, forKey: attributeConstants.locateMe)
            return true
        }
    }

    var doAddLocations: Bool
    {
        set
        {
            defaults.setBool(newValue, forKey: attributeConstants.addLocations)
        }

        get
        {
            if let hasDefault: Bool? = defaults.boolForKey(attributeConstants.addLocations)
            {
                return hasDefault!
            }

            defaults.setBool(true, forKey: attributeConstants.addLocations)
            return true
        }
    }

    var hasInitedLocations: Bool
    {
        set
        {
            defaults.setBool(newValue, forKey: attributeConstants.hasInitedLocations)
        }

        get
        {
            if let hasDefault: Bool? = defaults.boolForKey(attributeConstants.hasInitedLocations)
            {
                return hasDefault!
            }

            defaults.setBool(true, forKey: attributeConstants.hasInitedLocations)
            return true
        }
    }

    var useAppleMaps: Bool
    {
        set
        {
            defaults.setBool(newValue, forKey: attributeConstants.enableAppleMaps)
        }

        get
        {
            if let hasDefault: Bool? = defaults.boolForKey(attributeConstants.enableAppleMaps)
            {
                return hasDefault!
            }

            defaults.setBool(true, forKey: attributeConstants.enableAppleMaps)
            return true
        }
    }

    var useGoogleMaps: Bool
        {
        set
        {
            defaults.setBool(newValue, forKey: attributeConstants.enableGoogleMaps)
        }

        get
        {
            if let hasDefault: Bool? = defaults.boolForKey(attributeConstants.enableGoogleMaps)
            {
                return hasDefault!
            }

            defaults.setBool(false, forKey: attributeConstants.enableGoogleMaps)
            return true
        }
    }
}