//
//  FilterCollectionCell.swift
//  MapViewTest
//
//  Created by Richard E. Brown on 4/4/16.
//  Copyright © 2016 Zipcar. All rights reserved.
//

import Foundation
import UIKit

class FilterCollectionCell: UICollectionViewCell
{
    @IBOutlet weak var carImage: UIImageView!
    @IBOutlet weak var carLabel: UILabel!

    override func awakeFromNib()
    {
        super.awakeFromNib()

        self.carLabel.textColor = UIColor(red: 0x32, green: 0x3B, blue: 0x4C, alpha: 1.0)
        self.layer.cornerRadius = 5;
        self.layer.borderWidth = 2;
        self.layer.borderColor = UIColor.whiteColor().CGColor
    }

    func setSelected (selected: Bool)
    {
//    id changes = ^{
//    if ( selected )
//    {
//    _carLabel.textColor    = [UIColor ziphexColor:0x51A601];
//    self.layer.borderColor = [UIColor zipcarGreen].CGColor;
//    }
//    else
//    {
//    _carLabel.textColor = [UIColor ziphexColor:0x323B4C];
//    self.layer.borderColor = [UIColor whiteColor].CGColor;
//    }
//    };
//
//    [UIView transitionWithView:self
//    duration:0.25
//    options:UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionAllowAnimatedContent
//    animations:changes
//    completion:nil];
    }

}