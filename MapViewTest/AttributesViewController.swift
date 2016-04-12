//
//  AttributesViewController.swift
//  MapViewTest
//
//  Created by Richard E. Brown on 4/7/16.
//  Copyright © 2016 Zipcar. All rights reserved.
//

import Foundation
import UIKit

class AttributesViewController: UITableViewController
{
    var appDefaults: AppDefaults!

    @IBAction func tripsButton(sender: UISwitch)
    {
        appDefaults.tripsButtons = sender.on
    }

    @IBAction func filterToolsButton(sender: UISwitch)
    {
        appDefaults.toolBarFilter = sender.on
    }

    @IBAction func locationButton(sender: UISwitch)
    {
        appDefaults.locationButton = sender.on
    }

    @IBAction func locationSearchBar(sender: UISwitch)
    {
        appDefaults.locationSearchBar = sender.on
    }

    @IBAction func locateMeButton(sender: UISwitch)
    {
        appDefaults.locateMe = sender.on
    }

    @IBOutlet weak var tripsButtonsOutlet: UISwitch!
    @IBOutlet weak var filterToolsOutlet: UISwitch!
    @IBOutlet weak var locationButtonOutlet: UISwitch!
    @IBOutlet weak var locationSearchBarOutlet: UISwitch!
    @IBOutlet weak var locateMeOutlet: UISwitch!

    override func viewDidLoad ()
    {
        super.viewDidLoad()

        self.appDefaults = AppDefaults()
        tripsButtonsOutlet.on = self.appDefaults.tripsButtons
        filterToolsOutlet.on = self.appDefaults.toolBarFilter
        locationButtonOutlet.on = self.appDefaults.locationButton
        locationSearchBarOutlet.on = self.appDefaults.locationSearchBar
        locateMeOutlet.on = self.appDefaults.locateMe
    }
}