//
//  AppDelegate.swift
//  MapViewTest
//
//  Created by Richard E. Brown on 3/24/16.
//  Copyright © 2016 Zipcar. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
    {
        self.setupLocation()
        return true
    }

    func applicationWillResignActive(application: UIApplication)
    {
        LocationManager.sharedInstance.stopUpdatingLocation()
    }

    func applicationWillTerminate(application: UIApplication)
    {
        LocationManager.sharedInstance.stopUpdatingLocation()
    }

    private func setupLocation()
    {
        if LocationManager.sharedInstance.areLocationUpdatesPermissible
        {
            LocationManager.sharedInstance.startUpdatingLocation()
        }
        else
        {
            LocationManager.sharedInstance.promptForLocationAuthorization(.AuthorizedWhenInUse)
        }
    }
}

