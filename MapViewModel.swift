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
import CoreData
import JSQCoreDataKit
import Observable

extension MKPointAnnotation
{
    var loc: Location?
    {
        get
        {
            return nil
        }

        set { }
    }
}

class allAnnotation: MKPointAnnotation//, customAnnotation
{
    var pinImage: UIImage?
    {
        return nil
    }
}

class VehicleAvailAnnotation: allAnnotation
{
    override var pinImage: UIImage?
    {
        return UIImage(named: "greenpin")
    }

}

class NoVehicleAvailAnnotation: allAnnotation
{
    override var pinImage: UIImage?
    {
        return UIImage(named: "graypin")
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

let greenwich = CLLocationCoordinate2D(latitude: 0, longitude: 0)

class Address
{
    var changed = Observable(greenwich)
}
///•• changes for toolbar, trip type need to be handled here. 
///•• Also need to inform MapViewController when zoom/maprgn changes, to show redo search btn.

class MapViewModel: NSObject
{
    var mapView: MKMapView?
//    var mvmDelegate: MapViewModelDelegate?

    var mapRadius = 0.05
    var allowPinDraw = true

    var stack: CoreDataStack!

    // KVO mechanism
    let addressObj = Address()

    var addressLocation: CLLocationCoordinate2D?
    {
        didSet
        {
            addressObj.changed.value = addressLocation!
        }
    }

    var lastCenter: CLLocationCoordinate2D?

    /// View model owns the model. In a real world version of this, the model locations should be set or updated
    ///  for the current map region.
    //var locations = LocalLocations.sharedInstance

    override init()
    {
        super.init()

        addressObj.changed.subscribe(addressChangedHandler)

//        let model = CoreDataModel(name: modelName, bundle: modelBundle)
//        let factory = CoreDataStackFactory(model: model)
//        let result = factory.createStack()
//        stack = result.stack()!

//        if AppDefaults().hasInitedLocations == false
//        {
//            Location.setInitialLocations(stack.mainContext)
//            AppDefaults().hasInitedLocations = true
//        }

        if LocationHelper.count() == 0
        {
            LocationHelper.preload (Location.initialLocations())
        }
//        do
//        {
//            try Location.initialLocationsExist(stack.mainContext)
//        }
//        catch
//        {
//            let los = Location.setInitialLocations(stack.mainContext)
//        }

    }

    func addressChangedHandler (oldValue: CLLocationCoordinate2D, newValue: CLLocationCoordinate2D) -> ()
    {
        if newValue.latitude == 0 && newValue.longitude == 0
        {
            locateMe ()
        }

        if allowPinDraw
        {
            self.generatePins ()
        }

        self.mapView?.centerCoordinate = newValue
        self.mapView?.region = MKCoordinateRegionMake (addressLocation!, MKCoordinateSpanMake(mapRadius, mapRadius))

    }

    /// This assumes pattern of either round trip or one way locations. Not sure how unified search affects individual locations.
    ///
    func changeTripType (isOneWay: Bool)
    {
        /// Pass LocationService as a way of method injection. Unit test can use a fake service.
//        locations.populateLocations (addressLocation!, usageType: (isOneWay == true ? .OneWay : .RoundTrip))
    }

    func addNewLocationToModel (newPt: CLLocationCoordinate2D)
    {
        LocationHelper.insert(Location(id: Int32(getRandomNumber(1000000)), latitude: newPt.latitude, longitude: newPt.longitude, vehicleCount: Int16(getRandomNumber(10))))

        generatePins()
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
        if let locMapView = self.mapView//, stk = self.stack
        {
            locMapView.removeAnnotations(locMapView.annotations)

            do
            {
                let results = try Location.getLocationsInRange (locMapView.region.center, radius: locMapView.getRegionRadius())
//                let results = try Location.getLocationsInRange (stk.mainContext, centerCoordinate: locMapView.region.center, radius: locMapView.getRegionRadius())
//                let results = try locations.getLocationsInRange (locMapView.region.center, radius: locMapView.getRegionRadius())

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

    func createAnnotationForLocalLocation (localLocation: Location) -> MKPointAnnotation
//    func createAnnotationForLocalLocation (localLocation: LocalLocation) -> MKPointAnnotation
    {
        let annotation           = localLocation.vehicleCount?.intValue > 0 ? VehicleAvailAnnotation() : NoVehicleAvailAnnotation()
        annotation.coordinate    = CLLocationCoordinate2DMake((localLocation.latitude!.doubleValue), localLocation.longitude!.doubleValue)
        annotation.title         = "This place"
        annotation.subtitle      = "here"
        annotation.loc           = localLocation

        return annotation
    }

    func getCallout (localLocation: Location) -> MapCalloutViewController?
    {
        return nil
    }

    private func getRandomNumber (upperBound: Int) -> Int
    {
        return Int(arc4random_uniform(UInt32(upperBound)))
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

