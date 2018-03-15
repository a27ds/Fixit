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
    var date: Date
    var lat: Double
    var long: Double
    var image: UIImage
    var comment: String
    
    init(date: Date, lat: Double, long: Double, image: UIImage, comment: String) {
        self.date = date
        self.lat = lat
        self.long = long
        self.image = image
        self.comment = comment
    }
}
