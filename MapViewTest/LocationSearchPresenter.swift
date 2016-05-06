//
//  LocationSearchPresenter.swift
//  MapViewTest
//
//  Created by Richard E. Brown on 4/20/16.
//  Copyright © 2016 Zipcar. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit
import GoogleMaps
//import Observable

protocol LocationSearchView : NSObjectProtocol
{
    func numSections (sections: Int)
    func enableCurrentLocation ()
    func setRecentLocations (locations:[SearchLocation])
    func setFavoriteLocations (locations:[SearchLocation])
    func setAutoCompleteLocations (locations:[SearchLocation])
}

class Searching
{
    var textChanged = Observable("")
}

class LocationSearchPresenter
{
    var usingSearchBar = false
    //var searchBarContent: Observable<String>  cocoapod observable
    var searchBarContent = Searching()    // small, includeded code observable
    var mapRegion = MKCoordinateRegion()

    private let locService: SearchLocationService
    weak private var delegate: LocationSearchView?
    var currentLocation: CLLocationCoordinate2D?

    var search = MKLocalSearch (request: MKLocalSearchRequest())
    var locationResults = SearchLocationResults()
    let gmapFilter = GMapsFilterSetting()

    init (locService: SearchLocationService)
    {
        self.locService = locService
        delegate = nil
//        self.searchBarContent = Observable("")
//        searchBarContent.afterChange += {self.searchBarTextChanged($0,newValue: $1)}
        searchBarContent.textChanged.subscribe(searchBarTextChanged)
        gmapFilter.registerDefaults (gmapFilter.registrationDict)
    }

    func attachView (view: LocationSearchView, currLoc: CLLocationCoordinate2D?, currMapRegion: MKCoordinateRegion)
    {
        currentLocation = currLoc
        mapRegion = currMapRegion

        delegate = view
        delegate?.numSections(3)
        delegate?.setRecentLocations(locService.getRecentSearches())
        delegate?.setFavoriteLocations(locService.getFavoriteSearches())
    }

    func searchBarTextChanged (oldValue: String, newValue: String) -> ()
    {
        self.locationResults.removeAll (true)

        if newValue == ""
        {
            /// clear search results, reestablish 3 sections
            delegate?.numSections(3)
            delegate?.enableCurrentLocation()
        }
        else
        {
            if !AppDefaults().useAppleMaps && !AppDefaults().useGoogleMaps
            {
                let newLoc = SearchLocation(locationName: "Please turn on either or both", address: "Apple / Google Maps", machineAddress: self.currentLocation!, lastUsed: NSDate(), icon: .None)
                self.locationResults.results.append(newLoc)
                self.delegate!.setAutoCompleteLocations((self.locationResults.results))
            }

            if AppDefaults().useAppleMaps
            {
                if search.searching
                {
                    search.cancel()
                }

                let searchRequest = MKLocalSearchRequest()
                searchRequest.naturalLanguageQuery = "\(newValue)"
                searchRequest.region = mapRegion

                search = MKLocalSearch(request: searchRequest)

                search.startWithCompletionHandler { [weak self] (searchResponse, error) -> Void in
                    if error == nil
                    {
                        self?.handleSearchResults (searchResponse!)
                    }
                }
            }

            if AppDefaults().useGoogleMaps
            {
                let bounds = GMSCoordinateBounds (mapRegion: self.mapRegion)
                let filter = GMSAutocompleteFilter()

                filter.type = gmapFilter.currentFilter()// .NoFilter// .Region//.Geocode

                let placesClient = GMSPlacesClient()

                placesClient.autocompleteQuery (newValue, bounds: bounds, filter: nil, callback: { [weak self] (results, error: NSError?) -> Void in
                    guard error == nil else
                    {
                        print("Autocomplete error \(error)")
                        return
                    }

                    var remainingResults = results?.count

                    for result in results!
                    {
                        placesClient.lookUpPlaceID(result.placeID!, callback: {(place: GMSPlace?, error: NSError?) -> Void in
                            if let place = place
                            {
//                                print ("attributedPrimaryText = \(result.attributedPrimaryText), attributedSecondaryText = \(result.attributedSecondaryText)")
                                let newLoc = SearchLocation(locationName: result.attributedPrimaryText.string, address: (result.attributedSecondaryText?.string)!, machineAddress: place.coordinate, lastUsed: NSDate(), icon: .GPin)
                                self?.locationResults.results.append(newLoc)
                                remainingResults = remainingResults! - 1

                                if remainingResults == 0
                                {
                                    self?.delegate!.setAutoCompleteLocations((self?.locationResults.results)!)
                                }
                            }
                        })
                    }
                })
            }
        }
    }

    private func handleSearchResults ( searchResponse: MKLocalSearchResponse ) -> Void
    {
        for item in searchResponse.mapItems
        {
            let placeMark = item.placemark as CLPlacemark
            let itemLocation = CLLocation(latitude: placeMark.location!.coordinate.latitude, longitude: placeMark.location!.coordinate.longitude)

            if let title = item.name
            {
                let thisLocation = LocationAddress (place: placeMark, inCountry: "")
                let oneLocation = SearchLocation (locationName: title, address: thisLocation.getAddress(), machineAddress: itemLocation.coordinate, lastUsed: NSDate(), icon: .Pin)

//                self.locationResults.insert (oneLocation)   // insert would order by distance, not included in this impl.
                self.locationResults.results.append (oneLocation)
                delegate?.setAutoCompleteLocations (self.locationResults.results)
            }
        }
    }
}

extension GMSCoordinateBounds
{
    convenience init (mapRegion: MKCoordinateRegion)
    {
        let east = mapRegion.span.latitudeDelta / 2 - mapRegion.center.latitude
        let west = mapRegion.span.latitudeDelta / 2 + mapRegion.center.latitude
        let north = mapRegion.span.longitudeDelta / 2 - mapRegion.center.longitude
        let south = mapRegion.span.longitudeDelta / 2 + mapRegion.center.longitude

        self.init(coordinate:CLLocationCoordinate2D(latitude: east, longitude: north), coordinate:CLLocationCoordinate2D(latitude: west, longitude: south))
    }
}
