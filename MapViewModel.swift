//
//  MapViewModel.swift
//  zipcar
//
//  Created by Richard E. Brown on 3/22/16.
//  Copyright © 2016 Zipcar, Inc. All rights reserved.
//

//// mapzone.

import Foundation
import UIKit
import MapKit

extension MKPointAnnotation
{
    var loc: LocalLocation?
    {
        get
        {
            return nil
        }

        set { }
    }
}
//
//    var pinImage: UIImage?
//    {
//        get
//        {
//            return nil
//        }
//    }
//
//}

protocol pinImage: UIImage {}

protocol customAnnotation
{
    typealias IM: pinImage
    func getPinImage() -> IM
}

class allAnnotation: MKPointAnnotation, customAnnotation
{
    func getPinImage()
    {
        return nil
    }
}

class VehicleAvailAnnotation: allAnnotation
{
    override var pinImage: UIImage?
    {
        get
        {
            return UIImage(named: "greenpin")
        }
    }

}

class NoVehicleAvailAnnotation: allAnnotation
{
    override var pinImage: UIImage?
    {
        get
        {
            return UIImage(named: "graypin")
        }
    }
    
}

/// These and the extension below are 2 ways of doing the same thing. Keep for now.
public func ==(left: CLLocationCoordinate2D, right: CLLocationCoordinate2D) -> Bool
{
    return (left.latitude == right.latitude) && (left.longitude == right.longitude)
}

public func !=(left: CLLocationCoordinate2D, right: CLLocationCoordinate2D) -> Bool
{
    return !(left == right)
}

extension CLLocationCoordinate2D
{
    func equals (right: CLLocationCoordinate2D) -> Bool
    {
        return self.latitude == right.latitude && self.longitude == right.longitude
    }

    func notEquals (right: CLLocationCoordinate2D) -> Bool
    {
        return !(self.equals(right))
    }
}

///•• changes for toolbar, trip type need to be handled here. 
///•• Also need to inform MapViewController when zoom/maprgn changes, to show redo search btn.

class MapViewModel: NSObject
{
    var mapView: MKMapView?
//    var mvmDelegate: MapViewModelDelegate?

    var mapRadius = 0.05
    var allowPinDraw = false

    var addressLocation: CLLocationCoordinate2D?
    {
        didSet
        {
            if addressLocation!.latitude == 0 && addressLocation!.longitude == 0
            {
                locateMe ()
            }

            if allowPinDraw
            {
                self.generatePins ()
            }

            self.mapView?.centerCoordinate = addressLocation!
            self.mapView?.region = MKCoordinateRegionMake (addressLocation!, MKCoordinateSpanMake(mapRadius, mapRadius))
        }
    }

    var lastCenter: CLLocationCoordinate2D?

    /// View model owns the model. In a real world version of this, the model locations should be set or updated
    ///  for the current map region.
    var locations = LocalLocations.sharedInstance

    /// This assumes pattern of either round trip or one way locations. Not sure how unified search affects individual locations.
    ///
    func changeTripType (isOneWay: Bool)
    {
        /// Pass LocationService as a way of method injection. Unit test can use a fake service.
        locations.populateLocations (addressLocation!, usageType: (isOneWay == true ? .OneWay : .RoundTrip))
    }

    func locateMe ()
    {
        if let locMapView = mapView
        {
            locMapView.deselectAnnotation (locMapView.selectedAnnotations.first, animated: true)

            if LocationManager.sharedInstance.authorizationStatus == .AuthorizedWhenInUse ||
                LocationManager.sharedInstance.authorizationStatus == .AuthorizedAlways
            {
                if locMapView.centerCoordinate != locMapView.userLocation.coordinate &&
                    (locMapView.userLocation.coordinate.latitude != 0 && locMapView.userLocation.coordinate.longitude != 0)       // Shouldn't be necessary.
                {
                    locMapView.centerCoordinate = locMapView.userLocation.coordinate
                    addressLocation = locMapView.centerCoordinate
                    lastCenter = locMapView.centerCoordinate
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
    }

    // MARK: - handle VC Mapview Delegate changes

    func updateUserLocation (mapView: MKMapView, userLocation: MKUserLocation)
    {
        allowPinDraw = true
        addressLocation = mapView.centerCoordinate
        lastCenter = mapView.centerCoordinate
    }

    func updateWithMapRegionChange (mapView: MKMapView)
    {
        if let hasLast = lastCenter where hasLast != mapView.region.center
        {
            generatePins()
            lastCenter = mapView.region.center
        }
    }

//    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer
//    {
////        return mapView.configureOverlay (overlay)
//    }
//

    func viewForAnnotation (annotation: MKAnnotation) -> MKAnnotationView?
    {
        guard annotation is VehicleAvailAnnotation || annotation is NoVehicleAvailAnnotation else
        {
            return nil
        }

        let annotationView = getAnnotationView (annotation, identifier: "annotationViewID")

        annotationView.image = (annotation as! allAnnotation).pinImage
        annotationView.annotation = annotation
        annotationView.canShowCallout = true

        return annotationView
    }

    private func getAnnotationView (annotation: MKAnnotation, identifier withIdentifier: String) -> MKAnnotationView
    {
        if let annotationView = mapView?.dequeueReusableAnnotationViewWithIdentifier(withIdentifier)
        {
            return annotationView
        }

        return MKAnnotationView (annotation: annotation, reuseIdentifier: withIdentifier)
    }



    // MARK: Annotations

    func didSelectAnnotationView (view: MKAnnotationView)
    {
        guard view.annotation is VehicleAvailAnnotation || view.annotation is NoVehicleAvailAnnotation else
        {
            return
        }

        if let ziploc = (view.annotation as! MKPointAnnotation).loc
        {
            if let callout = self.getCallout(ziploc)
            {

//            callout.presentCalloutFromRect (view.bounds, inView: view, constrainedToView: mapView, animated: true)
                UIApplication.sharedApplication().keyWindow?.rootViewController!.presentViewController (callout, animated: true, completion: nil)
            }
        }
    }

    func generatePins ()
    {
//        mapView.removeAnnotations(mapView.annotations.filter({ (object) -> Bool in
//            return object is CustomAnno
//        }))
        if let locMapView = self.mapView
        {
            locMapView.removeAnnotations(locMapView.annotations)

            do
            {
                let results = try locations.getLocationsInRange (locMapView.region.center, radius: locMapView.getRegionRadius())

                for location in results
                {
                    let annotation = createAnnotationForLocalLocation(location)
                    locMapView.addAnnotation(annotation)
                }
            }
            catch
            {
                NSLog("MapViewModel.generatePins call to locations.getLocationsInRange failed due as no locations found within range.")
            }
        }
    }

    func createAnnotationForLocalLocation (localLocation: LocalLocation) -> MKPointAnnotation
    {
        let annotation           = localLocation.vehicleCount > 0 ? VehicleAvailAnnotation() : NoVehicleAvailAnnotation()
        annotation.coordinate    = CLLocationCoordinate2DMake(localLocation.lat, localLocation.long)
        annotation.title         = "This place"
        annotation.subtitle      = "here"
        annotation.loc           = localLocation

        return annotation
    }

    func getCallout (localLocation: LocalLocation) -> MapCalloutViewController?
    {
//        struct Holder
//        {
//            static let callout = SMCalloutView.platformCalloutView()
//        }

//        selectedLocalLocation?(localLocation: localLocation)
//        Holder.callout.delegate  = self
//        self.mapView.calloutView = Holder.callout

        //        let storyboard = UIStoryboard(name: "MapCalloutViewController", bundle: NSBundle.mainBundle())
        //        let calloutView = storyboard.instantiateViewControllerWithIdentifier("mapCalloutView") as! MapCalloutViewController

        //calloutView.view.frame           = CGRect(x: 0, y: 0, width: 240, height: 53)
//        Holder.callout.contentView       = calloutView.view

        //        calloutView.displayLocationInfo (localLocation)

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
//        return calloutView
        return nil
    }

}

extension MKMapView
{
    func getRegionRadius () -> Double
    {
        let radius = region.span.latitudeDelta > region.span.longitudeDelta ? region.span.latitudeDelta : region.span.longitudeDelta
        print ("New radius = \(radius). latitudeDelta = \(region.span.latitudeDelta). longitudeDelta = \(region.span.longitudeDelta).")
        return radius
    }
}

