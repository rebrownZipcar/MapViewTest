//
//  MapViewController.swift
//  zipcar
//
//  Copyright (c) 2016 Zipcar, Inc. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, CLLocationManagerDelegate, TripIndicatorDelegate, ToolBarDelegate, MKMapViewDelegate
{
    var mapViewModel = MapViewModel()
    var locationChangeObserver: AnyObject? = nil
    var usageType: LocalLocationUsageTypes = .Unified
    var desiredAccuracy: CLLocationAccuracy = LocationManager.sharedInstance.desiredAccuracy
    var distanceFilter: CLLocationDistance = LocationManager.sharedInstance.distanceFilter

    var locationManager = CLLocationManager()
    var startingLocation: CLLocationCoordinate2D?

    var toolbarVC: ToolBarViewController?
    var tripIndicatorVC: TripIndicatorViewController?

    lazy var locationUpdatedNotificationBlock: (NSNotification -> Void) = { [weak self] (locationUpdatedNotification: NSNotification) in
        guard let strongSelf = self else
        {
            return
        }

        if let locationChangeObserver = strongSelf.locationChangeObserver
        {
            NSNotificationCenter.defaultCenter().removeObserver(locationChangeObserver,
                                                                name: "location", object: LocationManager.sharedInstance)
        }

        if let location = locationUpdatedNotification.userInfo?["location"] as? CLLocation
        {
            strongSelf.mapViewModel.addressLocation = location.coordinate
        }
    }

    let defaultAddressLocation : CLLocationCoordinate2D = CLLocationCoordinate2DMake(42.351274, -71.047286)
    var doAddLocationObj = doAddLocation(add: true)
    var doNewLocation = false

    // MARK: Outlets

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var TripViewContainer: UIView!
    @IBOutlet weak var ToolBarViewContainer: UIView!

    @IBOutlet weak var locationSearchButton: UIButton!
    @IBOutlet weak var locateMeButton: UIButton!
    @IBOutlet weak var locateSearchBar: UISearchBar!

    // MARK: UIButton Actions

    @IBAction func searchLocationTappedButton(sender: UIButton)
    {
        mapView.deselectAnnotation(mapView.selectedAnnotations.first, animated: false)
    }

    @IBAction func locationMePressedButton(sender: UIButton)
    {
        mapViewModel.locateMe()
    }

    deinit
    {
        LocationManager.sharedInstance.desiredAccuracy = desiredAccuracy
        LocationManager.sharedInstance.distanceFilter = distanceFilter

        if let locationChangeObserver = locationChangeObserver
        {
            NSNotificationCenter.defaultCenter().removeObserver(locationChangeObserver,
                                                                name: "location", object: LocationManager.sharedInstance)
        }
    }

    // MARK: - View

    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.mapViewModel.mapView = self.mapView
        self.mapViewModel.addressLocation = self.startingLocation!

        doAddLocationObj.adding.subscribe(addLocation)

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleNewLocationTap(_:)))
        tap.numberOfTapsRequired = 1
        view.addGestureRecognizer(tap)
    }

    func updateAttributes ()
    {
        let appDefaults = AppDefaults()
        appDefaults.registerDefaults(appDefaults.registrationDict)

        if appDefaults.toolBarFilter
        {
            self.ToolBarViewContainer.hidden = false
            self.ToolBarViewContainer.userInteractionEnabled = true

            if let tbVC = self.toolbarVC where tbVC.carFilterButton != nil
            {
                tbVC.showToolBar()
            }
        }
        else
        {
            self.ToolBarViewContainer.hidden = true
            self.ToolBarViewContainer.userInteractionEnabled = false

            if let tbVC = self.toolbarVC where tbVC.carFilterButton != nil
            {
                tbVC.hideToolBar()
            }
        }

        if appDefaults.tripsButtons
        {
            self.TripViewContainer.hidden = false
            self.TripViewContainer.userInteractionEnabled = true
        }
        else
        {
            self.TripViewContainer.hidden = true
            self.TripViewContainer.userInteractionEnabled = false
        }

        self.locateMeButton.hidden = !appDefaults.locateMe
        self.locationSearchButton.hidden = !appDefaults.locationButton
        self.locateSearchBar.hidden = !appDefaults.locationSearchBar
    }

    func addLocation (oldValue: Bool, newValue: Bool) -> ()
    {
        doNewLocation = true
    }

    func handleNewLocationTap (sender:UITapGestureRecognizer)
    {
        if doNewLocation && sender.state == .Ended
        {
            let touchLocation = sender.locationInView(sender.view)
            let touchCoord = mapView.convertPoint(touchLocation, toCoordinateFromView: mapView)

            self.mapViewModel.addNewLocationToModel(touchCoord)
            doNewLocation = false
        }
    }

    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)

        loadLocationInformation()
        mapView.delegate = self
        updateAttributes()
    }

    func loadLocationInformation()
    {
        if let location = LocationManager.sharedInstance.lastKnownLocation()
        {
            let locationNotification = NSNotification(name: "location",
                                                      object: LocationManager.sharedInstance,
                                                      userInfo: ["location" : location])
            locationUpdatedNotificationBlock(locationNotification)
        }
        else if LocationManager.sharedInstance.areLocationUpdatesPermissible
        {
            locationChangeObserver = NSNotificationCenter.defaultCenter().addObserverForName("location",
                                                                                             object: LocationManager.sharedInstance,
                                                                                             queue: nil,
                                                                                             usingBlock: locationUpdatedNotificationBlock)

            LocationManager.sharedInstance.desiredAccuracy = kCLLocationAccuracyBest
            LocationManager.sharedInstance.distanceFilter = kCLDistanceFilterNone
            LocationManager.sharedInstance.startUpdatingLocation()
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        let destination = segue.destinationViewController

        if AppDefaults().toolBarFilter && segue.identifier == "toolBar segue"
        {
            self.toolbarVC = destination as? ToolBarViewController
            self.toolbarVC?.delegate = self
        }

        if AppDefaults().tripsButtons && segue.identifier == "trip indicator segue"
        {
            self.tripIndicatorVC = destination as? TripIndicatorViewController
            self.tripIndicatorVC?.delegate = self
        }

        if segue.identifier == "locationSearchViewController", let navVC = destination as? UINavigationController
        {
            if let locVC = navVC.viewControllers[0] as? LocationSearchViewController
            {
                locVC.currentLocation = mapViewModel.addressLocation
                locVC.currentRgn = self.mapView.region
                locVC.parentVC = self
            }
        }
    }

    func tripTypeChanged (isOneWay: Bool)
    {
        mapViewModel.changeTripType(isOneWay)
    }

    func filteredSelection ()
    {
//        mapViewModel.emulateFiltering ()
    }

    func adjustView (adjustSize: Int)
    {
        var token: dispatch_once_t = 0

        dispatch_once(&token)
        {
                // Move the center of the map down by 15% of the visible screen
//            self.mapView.frame.size.height += CGFloat(adjustSize)


//            self.mapView.visibleMapRect.origin.y -= Double(self.mapView.visibleMapRect.size.height * 0.15)
//            self.mapView.setVisibleMapRect (self.mapView.visibleMapRect, animated: true)
        }
    }

    // MARK: - Mapview Delegate

    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation)
    {
        mapViewModel.updateUserLocation (mapView, userLocation: userLocation)
    }

    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool)
    {
        print("Map region changed. center = \(mapView.region.center.latitude), \(mapView.region.center.longitude)")

        mapViewModel.updateWithMapRegionChange(mapView)
    }

//    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer
//    {
//        return mapViewModel.mapView(mapView, rendererForOverlay: overlay)
//    }

    func mapView (mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView])
    {
        animateAnnotations(views)
    }

    func mapView (mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView?
    {
        return mapViewModel.viewForAnnotation(annotation)
    }

    // MARK: Annotations

    func mapView (mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView)
    {
        mapViewModel.didSelectAnnotationView(view)
    }

    // MARK:  Lincoln's annotation animation code.

    func animateAnnotations (annotations: [MKAnnotationView])
    {
        guard !annotations.isEmpty else
        {
            return
        }

        annotations.forEach
            {
                annotation in
                annotation.alpha = 0.0
        }

        animate (annotations: annotations, index: 0)
    }

    private func animate (annotations annotations: [MKAnnotationView], index: Int)
    {
        guard index < annotations.count else
        {
            return
        }

        let individualDuration = 0.35
        let totalDuration = 2.0
        let annotation = annotations[index]
        let originalY = annotation.frame.origin.y

        annotation.frame.origin.y = -50
        annotation.alpha = 1.0

        UIView.animateWithDuration (individualDuration, animations: {
            annotation.frame.origin.y = originalY

            let interval: Double = (totalDuration - individualDuration) / Double(annotations.count)
            let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(interval * Double(NSEC_PER_SEC)))

            dispatch_after(delay, dispatch_get_main_queue(), {
                self.animate(annotations: annotations, index: index + 1)
            })
        })
    }

}
