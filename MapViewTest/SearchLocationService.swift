//
//  SearchLocationService.swift
//  MapViewTest
//
//  Created by Richard E. Brown on 4/20/16.
//  Copyright © 2016 Zipcar. All rights reserved.
//

import Foundation

class SearchLocationService
{
    func getRecentSearches () -> [SearchLocation]
    {
        return PreviouslySearchedAddresses().addresses
    }

    func getFavoriteSearches () -> [SearchLocation]
    {
        return FavoriteAddresses().addresses
    }
}