//
//  LocationSearchViewController.swift
//  MapViewTest
//
//  Created by Richard E. Brown on 4/20/16.
//  Copyright © 2016 Zipcar. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class LocationSearchViewController: UITableViewController, UISearchBarDelegate, LocationSearchView
{
    var numSections = 3

        /// These 3 vars are set by calling view controller. This is the endpoint of MVP to MVP communication.
    var currentLocation: CLLocationCoordinate2D?
    var currentRgn: MKCoordinateRegion?
    weak var parentVC: MapViewController!   // Convenience, but there may be a better way to get back there.


        /// The presenter and it's data for view use. In this case, the presenter is working off the model, 
        /// and then providing the view controller with the right category of information to be displayed.
    private let presenter = LocationSearchPresenter(locService: SearchLocationService())

        /// Local versions of model data, specifically for display.
    private var recentLocations: [SearchLocation] = []
    private var favoriteLocations: [SearchLocation] = []
    private var autoCompleteLocations: [SearchLocation] = []

    
    @IBAction func cancelSearch(sender: UIBarButtonItem)
    {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func filterResults(sender: UIBarButtonItem)
    {
        let mapStoryBoard = UIStoryboard(name: "MapView", bundle: NSBundle.mainBundle())

        if let gmapVC = mapStoryBoard.instantiateViewControllerWithIdentifier("gmapsFilterViewController") as? GMapPlacesFilter
        {
            self.navigationController?.pushViewController(gmapVC, animated: true)
        }
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()

        if let mapRgn = self.currentRgn
        {       /// Tried to do this in the presenter init call, but currentRgn not set then. This call completes 
                /// presenter initialization.
            presenter.attachView(self as LocationSearchView, currLoc: self.currentLocation, currMapRegion: mapRgn)
        }

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "filterIcon"), style: .Plain, target: self, action: #selector(LocationSearchViewController.filterResults))
    }

    // MARK: - LocationSearchView

    func numSections (sections: Int)
    {
        self.numSections = sections
    }

    func enableCurrentLocation ()
    {
        /// Is this a legitimate call in MVP?
        parentVC.mapViewModel.locateMe ()
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }

    func setRecentLocations (locations:[SearchLocation])
    {
        recentLocations = locations
        tableView?.reloadData()
    }

    func setFavoriteLocations (locations:[SearchLocation])
    {
        favoriteLocations = locations
        tableView?.reloadData()
    }

    func setAutoCompleteLocations (locations:[SearchLocation])
    {
        autoCompleteLocations = locations
        tableView?.reloadData()
    }

    // MARK: - Table view

    override func numberOfSectionsInTableView (tableView: UITableView) -> Int
    {
        if presenter.usingSearchBar
        {
            return 1
        }

        return 3
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        var sectionName = ""

        if section == 1
        {
            sectionName = NSLocalizedString("RECENT PLACES", comment: "User recent search location history")
        }
        else if section == 2
        {
            sectionName = NSLocalizedString("FAVORITE PLACES", comment: "User saved locations")
        }

        return sectionName
    }


    override func tableView (tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if section == 1
        {
            return recentLocations.count
        }
        else if section == 2
        {
            return favoriteLocations.count
        }
        else
        {
            return presenter.usingSearchBar ? autoCompleteLocations.count : 1
        }
    }

    override func tableView (tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("locationSearchCell", forIndexPath: indexPath) as! LocationSearchTableCell

        if presenter.usingSearchBar
        {
            if autoCompleteLocations.count > 0
            {
                let searchLocationResult = self.autoCompleteLocations[indexPath.row]

                cell.cellLocationTitle?.text = searchLocationResult.locationName
                cell.cellLocationSubtitle?.text = searchLocationResult.address
                cell.imageView?.image = UIImage(named: searchLocationResult.icon.rawValue)

               return cell
            }
        }
        else
        {
            if indexPath.section == 0
            {
                cell.cellLocationTitle?.text = NSLocalizedString("Current Location", comment: "Where the user is now.")
                cell.cellLocationSubtitle?.text = NSLocalizedString("-local locality here-", comment: "")
                cell.imageView?.image = UIImage(named: "SearchCurrentLocation")//"locationArrow")
            }
            else if indexPath.section == 1
            {
                let thisRecentLoc = self.recentLocations[indexPath.row]

                cell.cellLocationTitle?.text = thisRecentLoc.locationName
                cell.cellLocationSubtitle?.text = thisRecentLoc.address
                cell.imageView?.image = UIImage(named: thisRecentLoc.icon.rawValue)
            }
            else
            {
                let thisFavLoc = self.favoriteLocations[indexPath.row]

                cell.cellLocationTitle?.text = thisFavLoc.locationName
                cell.cellLocationSubtitle?.text = thisFavLoc.address
                cell.imageView?.image = UIImage(named: thisFavLoc.icon.rawValue)
            }
            
            return cell
        }

        return UITableViewCell(style: .Default, reuseIdentifier: "locationSearchCell")
    }

    override func tableView (tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        if presenter.usingSearchBar
        {
            let searchLocationResult = self.autoCompleteLocations[indexPath.row]
            let parent = self.parentVC

            parent.mapViewModel.addressLocation = searchLocationResult.machineAddress
            presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        }
        else
        {
            if indexPath.section == 0
            {
                // same as locateMe in mapVC
            }
            else if indexPath.section == 1
            {
                let thisRecentLoc = self.recentLocations[indexPath.row]
                let parent = self.parentVC

                parent.mapViewModel.addressLocation = thisRecentLoc.machineAddress
                presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
            }
            else // indexPath.section == 2
            {
                let thisFavLoc = self.favoriteLocations[indexPath.row]
                let parent = self.parentVC

                parent.mapViewModel.addressLocation = thisFavLoc.machineAddress
                presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }

    func searchBarShouldBeginEditing (searchBar: UISearchBar) -> Bool
    {
        presenter.usingSearchBar = true
        return true
    }

    func searchBar (searchBar: UISearchBar, textDidChange searchText: String)
    {
        if searchText == ""
        {
            autoCompleteLocations.removeAll()
            presenter.locationResults.removeAll(true)
            presenter.usingSearchBar = false
            tableView.reloadData()
        }
        else
        {
            presenter.usingSearchBar = true
            presenter.searchBarContent.textChanged.value = searchText
        }

//        tableView.reloadData()
    }

    func searchBarCancelButtonClicked (searchBar: UISearchBar)
    {
        autoCompleteLocations.removeAll()
        presenter.locationResults.removeAll(true)
        presenter.usingSearchBar = false
        tableView.reloadData()
    }

}