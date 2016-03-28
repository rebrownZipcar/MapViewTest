//
//  MapViewController.swift
//  zipcar
//
//  Created by Allen Wong on 4/17/15.
//  Copyright (c) 2015 Zipcar, Inc. All rights reserved.
//

import UIKit
import MapKit

enum SearchType: String
{
    case RoundTrip = "standard"
    case OneWay    = "oneway"
}

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

class MapViewController: UIViewController, MapViewModelDelegate
{
    var mapViewModel: MapViewModel!
    var locateMeButtonResponse: ((coordinate: CLLocationCoordinate2D)->())?     //going away
    var searchLocationResponse: (() -> ())?     //going away
    var tappedCarFilterResponse: (() -> ())?   //going away
    //var tappedRoundTrip: (()->())?   //going away
    //var tappedOneWay: (()->())?   //going away

    var locationManager = CLLocationManager()   // dferarro made singleton

    var lookupDispatchToken = 0

    // MARK: Outlets

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var toolBar: UIView!
    @IBOutlet weak var toolBarHeightContraint: NSLayoutConstraint!
    @IBOutlet weak var carFilterButton: UIButton!
    @IBOutlet weak var carFilterButtonLabelsView: UIView!
    @IBOutlet weak var dividerView: UIView!

    @IBOutlet weak var oneWayOptionView: UIView!
    @IBOutlet weak var roundTripButton: UIButton!
    @IBOutlet weak var selectedRoundTripIndicator: UIView!
    @IBOutlet weak var oneWayButton: UIButton!
    @IBOutlet weak var selectedOneWayIndicator: UIView!
    @IBOutlet weak var oneWayOptionViewHeightContraint: NSLayoutConstraint!

    @IBOutlet weak var locationSearchButton: UIButton!
    @IBOutlet weak var locateMeButton: UIButton!

    // MARK: UIButton Actions

    @IBAction func carFilterPressedButton (sender: UIButton)
    {
//        tappedCarFilterResponse?()
    }

    @IBAction func roundTripAction (sender: UIButton)
    {
        showSelectedRoundTrip()
        //tappedRoundTrip?()
    }

    @IBAction func oneWayAction (sender: UIButton)
    {
        showSelectedOneWay()
        //tappedOneWay?()
    }

    @IBAction func searchLocationTappedButton(sender: UIButton)
    {
        mapView.deselectAnnotation(mapView.selectedAnnotations.first, animated: false)
        searchLocationResponse?()
    }

    @IBAction func locationMePressedButton(sender: UIButton)
    {
        mapViewModel.locateMe()
    }

    //MARK: - Init
    convenience init (startLoc: CLLocationCoordinate2D, attributes: MapViewAttributes = MapViewAttributes())
    {
        self.init()
        mapViewModel = MapViewModel(startLoc: startLoc, mapView: mapView)

        if !attributes.hasFilterToolBar
        {
            self.hideToolBar()
        }
        else
        {
            self.showToolBar()
        }
        
        self.locateMeButton.hidden = !attributes.hasLocateMeButton
        self.locationSearchButton.hidden = !attributes.hasLocationSearch
        self.oneWayButton.hidden = !attributes.hasTripButtons
        self.selectedOneWayIndicator.hidden = !attributes.hasTripButtons
        self.roundTripButton.hidden = !attributes.hasTripButtons
        self.selectedRoundTripIndicator.hidden = !attributes.hasTripButtons
    }

//    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?)
//    {
//        super.init(nibName: "MapViewController", bundle: NSBundle.mainBundle())
//    }
//
//    required init(coder aDecoder: NSCoder)
//    {
//        super.init(coder: aDecoder)!
//    }

    //MARK: - View
    override func viewDidLoad()
    {
        super.viewDidLoad()
        toolBar.backgroundColor = UIColor.darkGrayColor()
        toolBar.alpha           = 0.95
        selectedOneWayIndicator.backgroundColor = UIColor.greenColor()
        selectedRoundTripIndicator.backgroundColor = UIColor.greenColor()

		oneWayButton.setAttributedTitle(formatOneWayBeta(false), forState: UIControlState.Normal)

        oneWayOptionView.layer.shadowColor = UIColor.grayColor().CGColor
        oneWayOptionView.layer.shadowOffset = CGSize(width: 0, height: 5)
        oneWayOptionView.layer.shadowOpacity = 0.7
    }

    //MARK: - Func
    func showSelectedRoundTrip()
    {
        roundTripButton.setTitleColor(UIColor.greenColor(), forState: UIControlState.Normal)
		oneWayButton.setAttributedTitle(formatOneWayBeta(false), forState: UIControlState.Normal)
        selectedOneWayIndicator.hidden = true
        selectedRoundTripIndicator.hidden = false
    }

    func showSelectedOneWay()
    {
		oneWayButton.setAttributedTitle(formatOneWayBeta(true), forState: UIControlState.Normal)
        roundTripButton.setTitleColor(UIColor.darkGrayColor(), forState: UIControlState.Normal)
        selectedRoundTripIndicator.hidden = true
        selectedOneWayIndicator.hidden = false

    }

    func hideOneWayOptionView()
    {
        oneWayOptionView.hidden = true
        oneWayOptionViewHeightContraint.constant = 0.0

        UIView.animateWithDuration(0.35, animations: { () -> Void in
            self.view.layoutIfNeeded()
            }, completion: nil)
    }

    func showOneWayOptionView()
    {
        oneWayOptionViewHeightContraint.constant = 40.0
        oneWayOptionView.hidden = false

        UIView.animateWithDuration(0.35, animations: { () -> Void in
            self.view.layoutIfNeeded()
            }, completion: nil)

        //self.mapView.setVisibleMapRect(self.mapView.visibleMapRect, edgePadding: UIEdgeInsetsMake(100, 0, 0, 0), animated: true)

    }

    func hideToolBar()
    {
        self.toolBarHeightContraint.constant = 0.0
        carFilterButton.hidden = true
        carFilterButtonLabelsView.hidden = true
        dividerView.hidden = true

        UIView.animateWithDuration(0.35, animations: { () -> Void in
            self.view.layoutIfNeeded()
            }, completion: nil)
    }

    func showToolBar()
    {
        self.toolBarHeightContraint.constant = 44.0
        carFilterButton.hidden = false
        carFilterButtonLabelsView.hidden = false
        dividerView.hidden = false

        UIView.animateWithDuration(0.35, animations: { () -> Void in
            self.view.layoutIfNeeded()
            }, completion: nil)

//        dispatch_once(&lookupDispatchToken) {
//            // Move the center of the map down by 15% of the visible screen
//            self.mapView.visibleMapRect.origin.y -= Double(self.mapView.visibleMapRect.size.height * 0.15)
//            self.mapView.setVisibleMapRect(self.mapView.visibleMapRect, animated: true)
//        }
    }

	func formatOneWayBeta (selected: Bool) -> NSAttributedString
	{
		let fontTitle = UIFont(name:"DINOffc-Medium", size:19.0)
		let fontBeta  = UIFont(name:"DINOffc", size:13.0)

		let textColor = selected ? UIColor.greenColor() : UIColor.darkGrayColor()

		let title = NSMutableAttributedString(string: "one-way", attributes: [NSFontAttributeName: fontTitle!, NSForegroundColorAttributeName: textColor])
		let beta  = NSAttributedString(string: " beta", attributes: [NSFontAttributeName: fontBeta!, String(kCTSuperscriptAttributeName): 1, NSForegroundColorAttributeName: textColor])
		title.appendAttributedString(beta)

		return title
	}

}
