//
//  FilterVehicleViewController.swift
//  MapViewTest
//
//  Created by Richard E. Brown on 4/4/16.
//  Copyright © 2016 Zipcar. All rights reserved.
//

import Foundation
import UIKit

class FilterVehicleViewController: UICollectionViewController
{

    var modelData = LocalModels()
    var styleData = LocalStyles()

    @IBOutlet weak var typeOrModel: UISegmentedControl!
    @IBOutlet weak var carCells: UICollectionView!

    @IBAction func changeTypeOrModel(sender: AnyObject)
    {
    }

//    override func viewDidLoad ()
//    {
//        super.viewDidLoad()

//        self.carCells.dataSource          = self.genDataSource;
//    _collectionView.accessibilityIdentifier = @"filterVehicleCollectionView";
//    }

    override func numberOfSectionsInCollectionView (collectionView: UICollectionView) -> Int
    {
        return 1
    }

    override func collectionView (collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
    }

    /*
    - (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
    {
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    RLMResults *models = [ZIPLocalModel allObjects];

    ZIPFilterCollectionCell * cell = (ZIPFilterCollectionCell *)[self.collectionView cellForItemAtIndexPath:indexPath];

    for model in models
    {
        if
    }

    if (cell.model)
    {
        {
            if (cell.model.modelId == 0 )
            {
                model.enabled = YES;
            }
            else
            {
                if (model.modelId == cell.model.modelId) 
                {
                    model.enabled = YES;
                }
                else
                {
                    model.enabled = NO;
                }
            }
        }
    }
    else
    {
        for model in models
        {
            if cell.style.styleId == 0
            {
                model.enabled = YES;
            }
            else
            {
                if model.styleId == cell.style.styleId
                {
                    model.enabled = YES;
                }
                else
                {
                    model.enabled = NO;
                }
            }
        }
    }

    [realm commitWriteTransaction];



    ZIPSearchResultViewController *searchVC = (ZIPSearchResultViewController* )self.navigationController.viewControllers[0];
    searchVC.tableView.contentOffset = CGPointMake(0, 0 - searchVC.tableView.contentInset.top);

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    [self.navigationController popViewControllerAnimated:YES];
    });
    }

    - (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath;
    {
    return CGSizeMake(142, 113);
    }

    -(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
    {
    return UIEdgeInsetsMake(18, 18, 18, 18);
    }
*/
}