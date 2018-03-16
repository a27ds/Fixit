//
//  MapViewController.swift
//  Fixit
//
//  Created by a27 on 2018-03-16.
//  Copyright © 2018 a27. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    // MARK: - Variabel Decalartions
    
    
    ///////////////////////////////////////////
    
    
    // MARK: - IBOutlets

    @IBOutlet weak var mapView: MKMapView!
    
    ///////////////////////////////////////////
    
    
    // MARK: - Views

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    ///////////////////////////////////////////
    
    
    // MARK: - IBActions

//    @IBAction func logoutButtonPressed(_ sender: UIBarButtonItem) {
////        dismiss(animated: true, completion: nil)
//    }
    
    @IBAction func listButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "showList_Segue", sender: self)
    }
    
    
    
    ///////////////////////////////////////////
    
    
}
