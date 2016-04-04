//
//  MapViewModel.swift
//  zipcar
//
//  Created by Richard E. Brown on 3/22/16.
//  Copyright © 2016 Zipcar, Inc. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class CustomAnno: MKPointAnnotation
{
    var loc: LocalLocation? = nil
}

class SearchAnno: MKPointAnnotation
{

}

///•• changes for toolbar, trip type need to be handled here. 
///•• Also need to inform MapViewController when zoom/maprgn changes, to show redo search btn.

class MapViewModel: NSObject, MKMapViewDelegate
{
    var mapView: MKMapView!
//    var mvmDelegate: MapViewModelDelegate?

    var desiredAccuracy: CLLocationAccuracy = LocationManager.sharedInstance.desiredAccuracy
    var distanceFilter: CLLocationDistance = LocationManager.sharedInstance.distanceFilter
    var locationChangeObserver: AnyObject? = nil
    var usageType: LocalLocationUsageTypes = .Unified

    var addressLocation: CLLocationCoordinate2D!
    {
        didSet
        {
            self.generatePins ()
        }
    }

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
            strongSelf.addressLocation = location.coordinate
        }
    }
    

    /// View model owns the model. In a real world version of this, the model locations should be set or updated
    ///  for the current map region.
    var locations = LocalLocations.sharedInstance

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


    init (startLoc: CLLocationCoordinate2D, mapView: MKMapView)
    {
        super.init()
        self.mapView = mapView

        if startLoc.latitude == 0 && startLoc.longitude == 0
        {
            locateMe ()
        }

        addressLocation = startLoc
        self.mapView.centerCoordinate = addressLocation
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

    func changeTripType (isOneWay: Bool)
    {
        locations.populateLocations (addressLocation, usageType: (isOneWay == true ? .OneWay : .RoundTrip))
    }


    func mapView (mapView: MKMapView, regionDidChangeAnimated animated: Bool)
    {
        //let distanceFromOldCenter = centerCoordiate.distanceFromLocation (CLLocation(latitude: addressLocation.latitude, longitude: addressLocation.longitude))
        // Call delegate protocol, so that locations get updated per region, or rather, center of new region.
        addressLocation = mapView.centerCoordinate

        /// Tell MapViewController to display redo search button.
    }

    func locateMe ()
    {
        mapView.deselectAnnotation (mapView.selectedAnnotations.first, animated: true)

        if LocationManager.sharedInstance.authorizationStatus == .AuthorizedWhenInUse ||
            LocationManager.sharedInstance.authorizationStatus == .AuthorizedAlways
        {
            if mapView.centerCoordinate.latitude != mapView.userLocation.coordinate.latitude &&
                mapView.centerCoordinate.longitude != mapView.userLocation.coordinate.longitude
            {
                mapView.centerCoordinate = mapView.userLocation.coordinate
                addressLocation = mapView.centerCoordinate
            }
        }
        else
        {
            let alert = UIAlertController(title: NSLocalizedString("Location Services Disabled", comment: "Alert Title for location services disabled"), message: NSLocalizedString("We need access to your location to show you the closest cars. You can update this in settings.", comment: "Prompt the user to turn on their location services"), preferredStyle: .Alert)

            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel the dialog"), style: .Cancel, handler: nil))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Settings", comment: "Device Settings"), style: .Default, handler: nil))

            if let rootController = UIApplication.sharedApplication().keyWindow?.rootViewController
            {
                rootController.presentViewController (alert, animated: true, completion: nil)
            }
        }
    }


    func mapView (mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView?
    {
        guard annotation is CustomAnno else//|| annotation is SearchAnno else
        {
            return nil
        }

        let annotationView = getAnnotationView (annotation, identifier: "annotationViewID")

        if let customAnnon = annotation as? CustomAnno where locations.locationCount() > 0, let ziploc = customAnnon.loc
        {
            annotationView.image = mapViewAnnotationImageFor(ziploc)
        }
        else
        {
            annotationView.image = UIImage(named: "greenpin")
        }

        annotationView.annotation = annotation
        annotationView.canShowCallout = true

        return annotationView
    }

    private func getAnnotationView (annotation: MKAnnotation, identifier withIdentifier: String) -> MKAnnotationView
    {
        if let annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(withIdentifier)
        {
            return annotationView
        }

        return MKAnnotationView (annotation: annotation, reuseIdentifier: withIdentifier)
    }


    // MARK:  Lincoln's annotation animation code.

    func mapView (mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView])
    {
        animateAnnotations(views)
    }

    private func animateAnnotations (annotations: [MKAnnotationView])
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

    // MARK: Annotations

    func mapView (mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView)
    {
        if view.annotation is MKUserLocation || view.annotation is SearchAnno
        {
            return
        }

//        let customAnno = view.annotation as! CustomAnno

        if let ziploc = (view.annotation as! CustomAnno).loc
        {
            let callout = self.getCallout(ziploc)

//            callout.presentCalloutFromRect (view.bounds, inView: view, constrainedToView: mapView, animated: true)
            UIApplication.sharedApplication().keyWindow?.rootViewController!.presentViewController (callout, animated: true, completion: nil)
        }
    }

    func generatePins ()
    {
        mapView.removeAnnotations(mapView.annotations.filter({ (object) -> Bool in
            return object is CustomAnno
        }))

        do
        {
            let results = try locations.getLocationsInRange (addressLocation, radius: mapView.getRegionRadius())

            for location in results
            {
                let annotation = createAnnotationForLocalLocation(location)
                mapView.addAnnotation(annotation)
            }
        }
        catch
        {
            NSLog("MapViewModel.generatePins call to locations.getLocationsInRange failed due as no locations found within range.")
        }
    }

    func mapViewAnnotationImageFor (localLocation: LocalLocation) -> UIImage
    {
        if localLocation.vehicleCount > 0 //|| (localLocation.isPoolingLocationAndAvailable() && dataSource.getIsFlexible() == false)
        {
            return UIImage(named: "greenpin")!
        }
        else
        {
            return UIImage(named: "graypin")!
        }
    }

    func createAnnotationForLocalLocation (localLocation: LocalLocation) -> MKPointAnnotation
    {
        let annotation           = CustomAnno()
        annotation.coordinate    = CLLocationCoordinate2DMake(localLocation.lat, localLocation.long)
        annotation.title         = "This place"
        annotation.loc           = localLocation

        return annotation
    }

    func getCallout (localLocation: LocalLocation) -> MapCalloutViewController
    {
//        struct Holder
//        {
//            static let callout = SMCalloutView.platformCalloutView()
//        }

//        selectedLocalLocation?(localLocation: localLocation)
//        Holder.callout.delegate  = self
//        self.mapView.calloutView = Holder.callout

        let storyboard = UIStoryboard(name: "MapCalloutViewController", bundle: NSBundle.mainBundle())
        let calloutView = storyboard.instantiateViewControllerWithIdentifier("mapCalloutView") as! MapCalloutViewController
        
        //calloutView.view.frame           = CGRect(x: 0, y: 0, width: 240, height: 53)
//        Holder.callout.contentView       = calloutView.view

        calloutView.displayLocationInfo (localLocation)

//        if oneWaySearch
//        {
//            calloutView.displayOneWaySearchLocation(localLocation)
//        }
//        else if oneWayDropOff
//        {
//            calloutView.displayOneWayDropOffLocation(localLocation)
//        }
//        else if dataSource.displayCarsCount()
//        {
//            calloutView.displayRoundTripWithCarsCount(localLocation)
//        }
//        else
//        {
//            calloutView.displayRoundTripWithOutCarsCount(localLocation)
//        }

//        return Holder.callout
        return calloutView
    }

}

extension MKMapView
{
    func getRegionRadius () -> Double
    {
        let latWidth = centerCoordinate.latitude - region.span.latitudeDelta
        let latHeight = centerCoordinate.longitude - region.span.longitudeDelta

        return latWidth > latHeight ? latWidth : latHeight
    }
}

//protocol MapViewModelDelegate
//{
//    func timesChanged (startTime: NSDate, endTime: NSDate)
//}