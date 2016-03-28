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
    var containedAnnotations: NSArray = []
    var clusterAnnotation: CustomAnno?
}

class SearchAnno: MKPointAnnotation
{

}

class MapViewModel : NSObject, MKMapViewDelegate
{
    var addressLocation: CLLocationCoordinate2D!
//    {
//        didSet
//        {
//            self.mapDelegate?.clearSearchAnno()
//        }
//    }

    //var currMapRegion
    weak var delegate : MapViewModelDelegate?
    var mapView : MKMapView!

    // View model owns the model. In a real world version of this, the model locations should be set or updated
    //  for the current map region.
    let locations = LocalLocations()        // [LocalLocation]()

    init (startLoc: CLLocationCoordinate2D, mapView: MKMapView)
    {
        super.init()
        addressLocation = startLoc
        self.mapView = mapView

        if addressLocation.latitude == 0 && addressLocation.longitude == 0
        {
            locateMe()
        }
        else
        {
        // Update locations based on current map region.
        }
    }

    func mapView (mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView?
    {
        guard annotation is CustomAnno || annotation is SearchAnno else
        {
            return nil
        }

        var annotationView : MKAnnotationView

        if let tempAnnotation = annotation as? SearchAnno
        {
            annotationView = getAnnotationView (tempAnnotation, identifier: "searchAnnotation")
            annotationView.annotation = tempAnnotation
            annotationView.enabled = true
            annotationView.canShowCallout = false
            //annotationView.hidden = dataSource.showAnnotationView()        // hide search pin if same as user location dot
            annotationView.image = UIImage(named: "searchPin")
        }
        else // CustomAnno
        {
            annotationView = getAnnotationView (annotation, identifier: "annotationViewID")

            if let customAnnon = annotation as? CustomAnno where locations.locationCount() > 0, let ziploc = customAnnon.loc
            {
                annotationView.image = mapViewAnnotationImageFor(ziploc)
            }
            else
            {
                annotationView.image = UIImage(named: "greenpin")
            }

            annotationView.annotation = annotation
            annotationView.canShowCallout = false
        }

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

    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView])
    {
        animateAnnotations(views)
    }

    private func animateAnnotations(annotations: [MKAnnotationView])
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
        animate(annotations: annotations, index: 0)
    }

    private func animate(annotations annotations: [MKAnnotationView], index: Int)
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

        UIView.animateWithDuration(individualDuration, animations:
            {
                annotation.frame.origin.y = originalY

                let interval: Double = (totalDuration - individualDuration) / Double(annotations.count)
                let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(interval * Double(NSEC_PER_SEC)))
                dispatch_after(delay, dispatch_get_main_queue(),
                    {
                        self.animate(annotations: annotations, index: index + 1)
                })
        })
    }



    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView)
    {
        if view.annotation is MKUserLocation || view.annotation is SearchAnno
        {
            return
        }

//        let customAnno = view.annotation as! CustomAnno

//        if !oneWayDropOff
//        {
//            view.image = UIImage(named: "selectedOneWayPin")
//        }

//        if let ziploc = customAnno.loc
//        {
//            let callout = self.getCallout(ziploc)
//            callout.presentCalloutFromRect (view.bounds, inView: view, constrainedToView: mapView, animated: true)
//        }
    }



    func mapView (mapView: MKMapView, regionDidChangeAnimated animated: Bool)
    {
        // Call delegate protocol, so that locations get updated per region, or rather, center of new region.
        // Also set addressLocation here.
    }

    func locateMe ()
    {
        //mapView.deselectAnnotation (mapView.selectedAnnotations.first, animated: false)

        // This would be suplanted by David F's location manager code.
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse ||
           CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedAlways
        {

            if mapView.centerCoordinate.latitude != mapView.userLocation.coordinate.latitude &&
                mapView.centerCoordinate.longitude != mapView.userLocation.coordinate.longitude
            {
                mapView.centerCoordinate = mapView.userLocation.coordinate
                //locateMeButtonResponse?(coordinate: mapView.userLocation.coordinate)
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

    func generatePins (coordinate: CLLocationCoordinate2D)
    {
        mapView.removeAnnotations(mapView.annotations.filter({ (object) -> Bool in
            return object is CustomAnno
        }))

        do
        {
            // NOTE: localLocations include both non-pooling and pooling locations
            let results = try locations.getLocationsInRange (coordinate, radius: mapView.getRegionRadius(), locationIDs: nil)

            for location in results
            {
//                if let localLocation = location as? ZIPLocalLocation
//                {
//                    if localLocation.isPoolingLocation() // handle pooling locations
//                    {
//                        if dataSource.getIsFlexible() == true
//                        {
//                            // skip pooling location in BBD search
//                            continue
//                        }
//                    }

                    let annotation = createAnnotationForLocalLocation(location)
                    mapView.addAnnotation(annotation)
//                }
            }
        }
        catch
        {
            NSLog("MapViewDelegate.generatePins call to ZIPLocalLocation.getLocalLocation failed due as no locations found within range.")
        }
    }

    func mapViewAnnotationImageFor(localLocation: LocalLocation) -> UIImage
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

    func createAnnotationForLocalLocation(localLocation: LocalLocation) -> MKPointAnnotation
    {
        let annotation           = CustomAnno()
        annotation.coordinate    = CLLocationCoordinate2DMake(localLocation.lat, localLocation.long)
        annotation.title         = "This place"
        annotation.loc           = localLocation

        return annotation
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

protocol MapViewModelDelegate : class
{

}