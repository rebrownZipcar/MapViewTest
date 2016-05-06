//
//  GMapPlacesFilter.swift
//  MapViewTest
//
//  Created by Richard E. Brown on 5/3/16.
//  Copyright © 2016 Zipcar. All rights reserved.
//

import Foundation
import UIKit

class GMapPlacesFilter: UITableViewController, GMapsFiltered
{
    let presenter = GMapPlacesFilterPresenter()

    @IBAction func filterSwitches(sender: UISwitch)
    {
        if sender.on
        {
            for btnOutlet in buttonOutlets
            {
                btnOutlet.on = false
                presenter.updateFilters(btnOutlet.tag, isOn: false)
            }

            buttonOutlets[sender.tag].on = true
        }

        presenter.updateFilters(sender.tag, isOn: self.buttonOutlets[sender.tag].on)
    }

    @IBOutlet var buttonOutlets: [UISwitch]!

//    @IBOutlet weak var geocodeOutlet: UISwitch!
//    @IBOutlet weak var addressOutlet: UISwitch!
//    @IBOutlet weak var establishmentOutlet: UISwitch!
//    @IBOutlet weak var regionOutlet: UISwitch!
//    @IBOutlet weak var cityOutlet: UISwitch!

    override func viewDidLoad ()
    {
        super.viewDidLoad()

        presenter.attachView(self as GMapsFiltered)
    }

    func filterChanged(tag: Int, isOn: Bool)
    {
        buttonOutlets[tag].on = isOn
    }
}