//
//  MapCalloutViewController.swift
//  zipcar
//
//  Copyright (c) 2016 Zipcar, Inc. All rights reserved.
//

import UIKit

struct MapCalloutViewAttributes
{
    var doShowInfoView: Bool
    var doShowVehicleCount: Bool
    var bgViewHasDefaultColor: Bool
    var bgViewOrange: Bool

    init (showInfoView: Bool = true, showVehicleCount: Bool = true, isBGViewDefault: Bool = true, isBGViewOrange: Bool = false)
    {
        doShowInfoView = showInfoView
        doShowVehicleCount = showVehicleCount
        bgViewHasDefaultColor = isBGViewDefault
        bgViewOrange = !bgViewHasDefaultColor && isBGViewOrange
    }
}

class MapCalloutViewController: UIViewController
{
    var tappedMoreInfoView: (() -> ())?

    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var parkingLabel: UILabel!
    @IBOutlet weak var carsBgView: UIView!
    @IBOutlet weak var carsLabel: UILabel!
    @IBOutlet weak var carsCount: UILabel!
    @IBOutlet weak var infoImageView: UIImageView!

    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.setUpView()
    }

    // MARK: UI Methods

    func setUpView()
    {
        carsBgView.backgroundColor = UIColor.greenColor()
        carsCount.textColor = UIColor.whiteColor()
        carsLabel.textColor = UIColor.whiteColor()
    }

    func displayLocationInfo (location: LocalLocation, attributes: MapCalloutViewAttributes = MapCalloutViewAttributes())
    {
        carsCount.hidden = !attributes.doShowInfoView
        carsLabel.hidden = !attributes.doShowInfoView
        infoImageView.hidden = attributes.doShowInfoView

        if !attributes.bgViewHasDefaultColor
        {
            if attributes.bgViewOrange
            {
                carsBgView.backgroundColor = UIColor.orangeColor()
            }
            else
            {
                carsBgView.backgroundColor = UIColor.whiteColor()
                carsLabel.textColor = UIColor.orangeColor()
                carsCount.textColor = UIColor.orangeColor()
            }
        }

        carsCount.text = "\(location.vehicleCount)"

        distanceLabel.text = "feet"//ZIPDistanceFormatter.abbreviatedDistanceFormat(location.distance).uppercaseString

//        addressLabel.text = location.address.isEmpty ? location.name : location.address
        addressLabel.text = "Some address"
        parkingLabel.text = "Zipcar"

//        if location.isPoolingLocation()
//        {
//            let zipcarOnDeck = NSLocalizedString("Zipcar on deck", comment: "branding, do not localized")
//            parkingLabel.text = ZIPParkingFormatter.formattedParking(zipcarOnDeck) as String
//        }
//        else
//        {
//            parkingLabel.text = ZIPParkingFormatter.formattedParking(location.parking) as String
//        }
    }
    
}
