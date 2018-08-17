//
//  artwork.swift
//  introMapKit
//
//  Created by Ios Dev on 20/07/2018.
//  Copyright © 2018 avchugunov. All rights reserved.
//

import MapKit
import Contacts

class Artwork: NSObject, MKAnnotation {
    let identifier = "marker"
    let title: String?
    let locationName: String
    let discipline: String
    let coordinate: CLLocationCoordinate2D
    let descr: String
    
    init(title: String, locationName: String, discipline: String, coordinate: CLLocationCoordinate2D, description: String) {
        self.title = title
        self.locationName = locationName
        self.discipline = discipline
        self.coordinate = coordinate
        self.descr = description
        
        super.init()
    }
    
    var subtitle: String? {
        return locationName
    }
    
    func mapItem() -> MKMapItem {
        let addressDict = [CNPostalAddressStreetKey: subtitle!]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDict)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title
        return mapItem
    }
}
