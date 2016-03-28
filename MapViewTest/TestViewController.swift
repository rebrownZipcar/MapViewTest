//
//  TestViewController.swift
//  MapViewTest
//
//  Created by Richard E. Brown on 3/24/16.
//  Copyright © 2016 Zipcar. All rights reserved.
//

import UIKit
import MapKit

class TestViewController: UITableViewController, MapViewModelDelegate
{
    @IBOutlet var ourTableView: UITableView!
    var tableHeader: MapViewController!

    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.tableView.reloadData()
        let addressLocation = CLLocationCoordinate2DMake(0.0, 0.0) as CLLocationCoordinate2D
        self.tableHeader = MapViewController(startLoc: addressLocation)
    }

}

