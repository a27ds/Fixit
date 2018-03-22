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

class Fault {
    var date: String!
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
        self.date = self.convertDateToString(date)
    }
    
    init(snapshot: DataSnapshot) {
        let snapshotValue = snapshot.value as! [String: Any]
        date = snapshotValue["date"] as! String
        lat = snapshotValue["lat"] as! Double
        long = snapshotValue["long"] as! Double
        imageURL = snapshotValue["imageURL"] as! String
        comment = snapshotValue["comment"] as! String
        key = snapshotValue["key"] as! String
    }
    
    func convertDateToString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        let dateString = formatter.string(from: date)
        return dateString
    }
    
    func toAnyObject() -> Any {
        return ["date": date,
                "lat": lat,
                "long": long,
                "imageURL": imageURL,
                "comment": comment,
                "key": key]
    }
}
