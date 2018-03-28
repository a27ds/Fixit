//
//  Fault.swift
//  Fixit
//
//  Created by a27 on 2018-03-15.
//  Copyright © 2018 a27. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import Firebase
import MapKit

class Fault {
    var date: Date
    var lat: Double
    var long: Double
    var imageURL: String
    var comment: String
    var key: String
    
    init(date: Date, lat: Double, long: Double, imageURL: String, comment: String, key: String) {
        self.lat = lat
        self.long = long
        self.imageURL = imageURL
        self.comment = comment
        self.key = key
        self.date = date
    }
    
    init(snapshot: DataSnapshot) {
        let snapshotValue = snapshot.value as! [String: Any]
        lat = snapshotValue["lat"] as! Double
        long = snapshotValue["long"] as! Double
        imageURL = snapshotValue["imageURL"] as! String
        comment = snapshotValue["comment"] as! String
        key = snapshotValue["key"] as! String
        date = Fault.convertStringToDate(snapshotValue["date"] as! String)
    }
    
    static func convertDateToString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        let dateString = formatter.string(from: date)
        return dateString
    }
    
    static func getRidOfTimeInDateAsString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    static func convertStringToDate(_ date: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        let dateString = formatter.date(from: date)
        return dateString!
    }
    
//    static func addPin(date: Date, lat: Double, long: Double) -> MKAnnotation {
//        let date = convertDateToString(date)
//        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
//        return AnnotationPin(title: date, coordinate: coordinate)
//    }
    
    func toAnyObject() -> Any {
        return ["date": Fault.convertDateToString(date),
                "lat": lat,
                "long": long,
                "imageURL": imageURL,
                "comment": comment,
                "key": key]
    }
}
