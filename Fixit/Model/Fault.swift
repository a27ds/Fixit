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

class Fault {
    var date: String!
    var lat: Double
    var long: Double
    var image: UIImage
    var comment: String
    
    init(date: Date, lat: Double, long: Double, image: UIImage, comment: String) {
        self.lat = lat
        self.long = long
        self.image = image
        self.comment = comment
        self.date = self.convertDateToString(date)
    }
    
    func convertDateToString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        let dateString = formatter.string(from: date)
        return dateString
    }
    
}

class FirebaseFault {
    var date: String = ""
    var lat: Double = 0.0
    var long: Double = 0.0
    var image: String = ""
    var comment: String = ""
    var key: String = ""
}
