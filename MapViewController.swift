//
//  MapViewController.swift
//  zipcar
//
//  Created by Allen Wong on 4/17/15.
//  Copyright (c) 2015 Zipcar, Inc. All rights reserved.
//

import UIKit
import MapKit


struct MapViewAttributes
{
    var hasFilterToolBar: Bool
    var hasTripButtons: Bool
    var hasLocationSearch: Bool
    var hasLocateMeButton: Bool

    init (filterToolBar: Bool = false, tripButtons: Bool = false, locationSearch: Bool = false, locateMe: Bool = false)
    {
        hasFilterToolBar = filterToolBar
        hasTripButtons = tripButtons
        hasLocationSearch = locationSearch
        hasLocateMeButton = locateMe
    }
}

class MapViewController: UIViewController, TripIndicatorDelegate
{
    var mapViewModel: MapViewModel!

    var locationManager = CLLocationManager()
    var startingLocation: CLLocationCoordinate2D?
    var attributes: MapViewAttributes?

    var toolbarVC: ToolBarViewController?
    var tripIndicatorVC: TripIndicatorViewController?

    // MARK: Outlets

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var TripViewContainer: UIView!
    @IBOutlet weak var ToolBarViewContainer: UIView!

    @IBOutlet weak var locationSearchButton: UIButton!
    @IBOutlet weak var locateMeButton: UIButton!
    @IBOutlet weak var redoSearch: UIButton!

    // MARK: UIButton Actions

    @IBAction func searchLocationTappedButton(sender: UIButton)
    {
        mapView.deselectAnnotation(mapView.selectedAnnotations.first, animated: false)
//        instantiateViewControllerWithIdentifier("searchLocationsTableViewController")
    }

    @IBAction func locationMePressedButton(sender: UIButton)
    {
        mapViewModel.locateMe()
    }

    @IBAction func redoLocationSearch(sender: AnyObject)
    {
        self.redoSearch.hidden = true
    }

    // MARK: - View

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        mapViewModel = MapViewModel(startLoc: startingLocation!, mapView: mapView)
        self.redoSearch.hidden = true

        if let attributes =  self.attributes
        {
            if attributes.hasFilterToolBar
            {
                self.ToolBarViewContainer.hidden = false
                self.ToolBarViewContainer.userInteractionEnabled = true
            }
            else
            {
                self.ToolBarViewContainer.hidden = true
                self.ToolBarViewContainer.userInteractionEnabled = false
            }

            if attributes.hasTripButtons
            {
                self.TripViewContainer.hidden = false
                self.TripViewContainer.userInteractionEnabled = true
            }
            else
            {
                self.TripViewContainer.hidden = true
                self.TripViewContainer.userInteractionEnabled = false
            }

            self.locateMeButton.hidden = !attributes.hasLocateMeButton
            self.locationSearchButton.hidden = !attributes.hasLocationSearch
        }
    }

    override func viewWillAppear(animated: Bool)
    {
        mapViewModel.loadLocationInformation()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        let destination = segue.destinationViewController

        if self.attributes!.hasFilterToolBar && segue.identifier == "toolBar segue"
        {
            self.toolbarVC = destination as? ToolBarViewController
        }

        if self.attributes!.hasTripButtons && segue.identifier == "trip indicator segue"
        {
            self.tripIndicatorVC = destination as? TripIndicatorViewController
        }
    }

    func tripTypeChanged (isOneWay: Bool)
    {
        mapViewModel.changeTripType(isOneWay)
    }
}
