//
//  AnnotationPin.swift
//  Fixit
//
//  Created by a27 on 2018-03-24.
//  Copyright © 2018 a27. All rights reserved.
//

import MapKit

class AnnotationPin: NSObject, MKAnnotation {
    var title: String?
    var coordinate: CLLocationCoordinate2D
    var fault: Fault
    
    init(title: String, coordinate: CLLocationCoordinate2D, fault: Fault) {
        self.title = title
        self.coordinate = coordinate
        self.fault = fault
    }
    
    func mapItem() -> MKMapItem {
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title
        return mapItem
    }
}
