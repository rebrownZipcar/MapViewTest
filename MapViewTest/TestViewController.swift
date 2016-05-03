//
//  TestViewController.swift
//  MapViewTest
//
//  Created by Richard E. Brown on 3/24/16.
//  Copyright © 2016 Zipcar. All rights reserved.
//

import UIKit
import MapKit
import Observable

struct doAddLocation
{
    var adding: Observable<Bool>

    init (add: Bool)
    {
        self.adding = Observable(add)
    }
}


class TestViewController: UITableViewController
{
    var tableHeader: MapViewController!
    var locationModel = LocalLocations.sharedInstance

    @IBOutlet var ourTableView: UITableView!
    @IBOutlet weak var addLocationOutlet: UIBarButtonItem!

    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.tableView.reloadData()

        ///•• Initial map center would be set to most favorite location, most recent location, or (0.0, 0.0) to use current location.
        let addressLocation = CLLocationCoordinate2DMake(42.351274, -71.047286) as CLLocationCoordinate2D
        let storyboard = UIStoryboard(name: "MapView", bundle: NSBundle.mainBundle())

        if let mapVC = storyboard.instantiateViewControllerWithIdentifier("mapViewController") as? MapViewController
        {
            mapVC.startingLocation = addressLocation
            self.tableHeader = mapVC
            self.ourTableView.tableHeaderView = self.tableHeader.view
        }

        addLocationOutlet.enabled = AppDefaults().doAddLocations
    }

    override func viewDidAppear (animated: Bool)
    {
        super.viewDidAppear(animated)
        self.tableHeader.viewDidAppear(animated)
        refresh()
    }

    @IBAction func addLocationAction(sender: UIBarButtonItem)
    {
        tableHeader.doAddLocationObj.adding.value = true
    }

    // MARK: - Table view data source

//    override func tableView (tableView: UITableView, numberOfRowsInSection section: Int) -> Int
//    {
//        return 1
//    }

//    override func tableView (tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
//    {
//        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
//
//        let item = locationModel[indexPath.row]
//        cell.textLabel?.text = item.title
//        cell.detailTextLabel?.text = item.amount

//        return cell
//    }

//    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
//    {
//        return true
//    }
//
//    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
//    {
//    }

    // MARK: - IBActions

    func refresh()
    {
        tableView.reloadData()
    }

    func updateUsageTimes (startTime: NSDate, endTime: NSDate)
    {
        ///•• This would be called on change of start and/or end times, usually via a date picker view.
        locationModel.startTime = startTime
        locationModel.endTime = endTime
    }
}







