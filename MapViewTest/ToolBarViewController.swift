//
//  ToolBarViewController.swift
//  MapViewTest
//
//  Created by Richard E. Brown on 4/1/16.
//  Copyright © 2016 Zipcar. All rights reserved.
//

import Foundation
import UIKit

class ToolBarViewController: UIViewController
{
    @IBOutlet weak var toolBar: UIView!
    @IBOutlet weak var toolBarHeightContraint: NSLayoutConstraint!
    @IBOutlet weak var carFilterButton: UIButton!
    @IBOutlet weak var carFilterButtonLabelsView: UIView!
    @IBOutlet weak var dividerView: UIView!

    @IBAction func carFilterPressedButton (sender: UIButton)
    {
        //       instantiateViewControllerWithIdentifier("transitionToFilterViewController")
        self.performSegueWithIdentifier("transitionToFilterViewController", sender: nil)
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()

        toolBar.backgroundColor = UIColor.darkGrayColor()
        toolBar.alpha           = 0.95
    }

    func hideToolBar()
    {
        //        self.toolBarHeightContraint.constant = 0.0
        carFilterButton.hidden = true
        carFilterButtonLabelsView.hidden = true
        dividerView.hidden = true

        UIView.animateWithDuration(0.35, animations: { () -> Void in
            self.view.layoutIfNeeded()
            }, completion: nil)
    }

    func showToolBar()
    {
        //        self.toolBarHeightContraint.constant = 44.0
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
}
