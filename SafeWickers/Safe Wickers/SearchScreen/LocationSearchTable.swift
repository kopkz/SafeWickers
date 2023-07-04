//
//  LocationSearchTable.swift
//  Safe Wickers
//
//  Created by 匡正 on 20/4/20.
//  Copyright © 2020 匡正. All rights reserved.
//

import UIKit
import MapKit

class LocationSearchTable : UITableViewController {
    var handleMapSearchDelegate: HandleMapSearch? = nil
    var matchingItems:[MKMapItem] = []
    func parseAddress(selectedItem:MKPlacemark) -> String {
        // put a space between "4" and "Melrose Place"
        let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
        // put a comma between street and city/state
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
        // put a space between "Washington" and "DC"
        let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " " : ""
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            // street number
            selectedItem.subThoroughfare ?? "",
            firstSpace,
            // street name
            selectedItem.thoroughfare ?? "",
            comma,
            // city
            selectedItem.locality ?? "",
            secondSpace,
            // state
            selectedItem.administrativeArea ?? ""
        )
        return addressLine
    }
    
}

extension LocationSearchTable : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
//                //ignoring user
//        UIApplication.shared.beginIgnoringInteractionEvents()
        
        
        //create request
        let searchRequest = MKLocalSearch.Request()
        //searchRequest.
        searchRequest.naturalLanguageQuery = searchController.searchBar.text
        searchRequest.region = MKCoordinateRegion.init(center: CLLocationCoordinate2D.init(latitude: -38.0, longitude: 145.0), latitudinalMeters: 200000, longitudinalMeters: 400000)
        
        let activeSearch = MKLocalSearch(request: searchRequest)
        
        
        activeSearch.start { response, _ in
            guard let response = response else {
                return
            }
            self.matchingItems = response.mapItems
            self.tableView.reloadData()
        }
    }
}

extension LocationSearchTable {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationSearchcell")!
        let selectedItem = matchingItems[indexPath.row].placemark
        cell.textLabel?.text = selectedItem.name
        cell.detailTextLabel?.text = parseAddress(selectedItem: selectedItem)
        return cell
    }
    
}

extension LocationSearchTable {
    
    override func  tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = matchingItems[indexPath.row].placemark
        handleMapSearchDelegate?.createSearchLocation(placemark: selectedItem)
        
        //Hide search bar and result
        dismiss(animated: true, completion: nil)
    }
    
}
