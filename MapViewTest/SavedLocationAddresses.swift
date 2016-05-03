//
//  SavedLocationAddresses.swift
//  MapViewTest
//
//  Created by Richard E. Brown on 4/20/16.
//  Copyright © 2016 Zipcar. All rights reserved.
//

import UIKit
import CoreLocation

struct prefConstants
{
    static let prevAddressArray = "prevAddressArray"
    static let maxPreviousAddresses = 4
    static let favAddressArray = "favAddressArray"
    static let maxFavoriteAddresses = 5
}


class PreviouslySearchedAddresses
{
    private var userDefaults: NSUserDefaults
    var maxAddr: Int

    var addresses: [SearchLocation]
    {
        get
        {
            if let savedAddresses : AnyObject = userDefaults.objectForKey (prefConstants.prevAddressArray)
            {
                if let addresses : AnyObject = NSKeyedUnarchiver.unarchiveObjectWithData(savedAddresses as! NSData)
                {
                    return (addresses as! [SearchLocation]).sort {$0.lastUsed.timeIntervalSince1970 > $1.lastUsed.timeIntervalSince1970}
                }
            }
            return []
        }

        set (addresses)
        {
            let addressListData = NSKeyedArchiver.archivedDataWithRootObject (addresses as! AnyObject)
            userDefaults.setObject (addressListData, forKey: prefConstants.prevAddressArray)
            userDefaults.synchronize()
        }
    }

    init ()
    {
        userDefaults = NSUserDefaults.standardUserDefaults()
        maxAddr = prefConstants.maxPreviousAddresses
    }

    func addNewAddress (lastLocation: SearchLocation)
    {
        var savedAddresses = self.addresses

        if savedAddresses.count > maxAddr
        {
            savedAddresses.removeFirst()
        }

        savedAddresses.append(lastLocation)
        self.addresses = savedAddresses
    }

    func updateAddressDateUsed (index: Int) -> SearchLocation
    {
        var savedAddresses = self.addresses

        savedAddresses[index].lastUsed = NSDate()

        self.addresses = savedAddresses

        return savedAddresses[index]
    }
}

class FavoriteAddresses : PreviouslySearchedAddresses
{
    override var addresses: [SearchLocation]
    {
        get
        {
            if let savedAddresses : AnyObject = userDefaults.objectForKey (prefConstants.favAddressArray)
            {
                if let addresses : AnyObject = NSKeyedUnarchiver.unarchiveObjectWithData(savedAddresses as! NSData)
                {
                    return addresses as! [SearchLocation]
                }
            }
            else
            {
                /// needs call to server. Mock, for now
                // ZIPUserDataService.sharedUserDataService().getUserInformationWithBlock { [weak self] (profile: ZIPUserProfile!, error: NSError!) -> Void in
                // profile.addressesObject as? Array<ZIPAddress>
                let newAddrs = [SearchLocation(locationName: "", address: "3 Oak Grove Rd", machineAddress: CLLocationCoordinate2D(latitude: 40.8355,longitude: -74.2778), lastUsed: NSDate(), icon: .None),
                                SearchLocation(locationName: "", address: "35 Thomson Place", machineAddress: CLLocationCoordinate2D(latitude: 42.3513,longitude: -71.047), lastUsed: NSDate(), icon: .Home),
                                SearchLocation(locationName: "", address: "1000 Airport Boulevard", machineAddress: CLLocationCoordinate2D(latitude: 40.496,longitude: -80.2567), lastUsed: NSDate(), icon: .Airport),
                                SearchLocation(locationName: "", address: "Pittsburgh", machineAddress: CLLocationCoordinate2D(latitude: 40.4406,longitude: -79.99590000000001), lastUsed: NSDate(), icon: .None)]
                return newAddrs
            }
            return []
        }

        set (addresses)
        {
            let addressListData = NSKeyedArchiver.archivedDataWithRootObject (addresses as! AnyObject)
            userDefaults.setObject (addressListData, forKey: prefConstants.favAddressArray)
            userDefaults.synchronize()
        }
    }

    override init ()
    {
        super.init()
        userDefaults = NSUserDefaults.standardUserDefaults()
        maxAddr = prefConstants.maxFavoriteAddresses
    }
}
