//
//  FaultView.swift
//  Fixit
//
//  Created by a27 on 2018-03-27.
//  Copyright © 2018 a27. All rights reserved.
//

import MapKit

class FaultView: MKMarkerAnnotationView {
    
    override var annotation: MKAnnotation? {
        willSet {
            if (newValue as? AnnotationPin) != nil {
                clusteringIdentifier = "fault"
                markerTintColor = UIColor.black
                glyphText = NSLocalizedString("fault", comment: "")
                displayPriority = .defaultHigh
                canShowCallout = true
                rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
                rightCalloutAccessoryView?.tintColor = UIColor.black
            }
        }
    }
}
