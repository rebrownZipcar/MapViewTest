//
//  GMapPlacesFilterPresenter.swift
//  MapViewTest
//
//  Created by Richard E. Brown on 5/3/16.
//  Copyright © 2016 Zipcar. All rights reserved.
//

import Foundation

protocol GMapsFiltered
{
    func filterChanged (tag: Int, isOn: Bool)
}

class GMapPlacesFilterPresenter
{
    let filterSettings = GMapsFilterSetting ()
    private var delegate: GMapsFiltered?

    init ()
    {
        filterSettings.registerDefaults (filterSettings.registrationDict)
        delegate = nil
    }

    func attachView (view: GMapsFiltered)
    {
        delegate = view
        updateFilters (-1, isOn: false)
    }

    func updateFilters (buttonTag: Int, isOn: Bool)
    {
        if buttonTag == -1
        {
            delegate?.filterChanged(0, isOn: filterSettings.geocodeFilter)
            delegate?.filterChanged(1, isOn: filterSettings.addressFilter)
            delegate?.filterChanged(2, isOn: filterSettings.establishmentFilter)
            delegate?.filterChanged(3, isOn: filterSettings.regionFilter)
            delegate?.filterChanged(4, isOn: filterSettings.cityFilter)
        }
        else
        {
            switch buttonTag
            {
                case 0:
                    filterSettings.geocodeFilter = isOn
                case 1:
                    filterSettings.addressFilter = isOn
                case 2:
                    filterSettings.establishmentFilter = isOn
                case 3:
                    filterSettings.regionFilter = isOn
                default:
                    filterSettings.cityFilter = isOn
            }
        }
    }
}