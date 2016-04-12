//
//  TripIndicatorViewController.swift
//  MapViewTest
//
//  Created by Richard E. Brown on 4/1/16.
//  Copyright © 2016 Zipcar. All rights reserved.
//

import Foundation
import UIKit

class TripIndicatorViewController: UIViewController
{
    var delegate: TripIndicatorDelegate?

    @IBOutlet weak var oneWayOptionView: UIView!
    @IBOutlet weak var roundTripButton: UIButton!
    @IBOutlet weak var selectedRoundTripIndicator: UIView!
    @IBOutlet weak var oneWayButton: UIButton!
    @IBOutlet weak var selectedOneWayIndicator: UIView!
    @IBOutlet weak var oneWayOptionViewHeightContraint: NSLayoutConstraint!

    @IBAction func roundTripAction (sender: UIButton)
    {
        showSelectedRoundTrip()
        delegate?.tripTypeChanged (false)
    }

    @IBAction func oneWayAction (sender: UIButton)
    {
        showSelectedOneWay()
        delegate?.tripTypeChanged (true)
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()

        selectedOneWayIndicator.backgroundColor = UIColor.greenColor()
        selectedRoundTripIndicator.backgroundColor = UIColor.greenColor()

        oneWayButton.setAttributedTitle (formatOneWay (false), forState: UIControlState.Normal)

        oneWayOptionView.layer.shadowColor = UIColor.grayColor().CGColor
        oneWayOptionView.layer.shadowOffset = CGSize(width: 0, height: 5)

        oneWayOptionView.layer.shadowOpacity = 0.7
    }

    func showSelectedRoundTrip()
    {
        roundTripButton.setTitleColor (UIColor.greenColor(), forState: UIControlState.Normal)
        oneWayButton.setAttributedTitle (formatOneWay (false), forState: UIControlState.Normal)
        selectedOneWayIndicator.hidden = true
        selectedRoundTripIndicator.hidden = false
    }

    func showSelectedOneWay()
    {
        oneWayButton.setAttributedTitle (formatOneWay (true), forState: UIControlState.Normal)
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

    func formatOneWay (selected: Bool) -> NSAttributedString
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

protocol TripIndicatorDelegate
{
    func tripTypeChanged (isOneWay: Bool)
}