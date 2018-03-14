//
//  addBorder.swift
//  Fixit
//
//  Created by a27 on 2018-03-14.
//  Copyright © 2018 a27. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    enum ViewSide {
        case Left, Right, Top, Bottom
    }
    
    func addBorder(side: ViewSide, color: CGColor, thickness: CGFloat) {
        
        let border = CALayer()
        border.backgroundColor = color
        
        switch side {
        case .Left:
            border.frame = CGRect(x: 0, y: 0, width: thickness, height: frame.height)
        case .Right:
            border.frame = CGRect(x: self.frame.size.width - thickness, y: 0, width: thickness, height: frame.height)
        case .Top:
            border.frame = CGRect(x: 0, y: 0, width: frame.width, height: thickness)
        case .Bottom:
            border.frame = CGRect(x: 0, y: self.frame.size.height - thickness, width: frame.width, height: thickness)
        }
        layer.addSublayer(border)
    }
}

