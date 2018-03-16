//
//  ListViewController.swift
//  Fixit
//
//  Created by a27 on 2018-03-16.
//  Copyright © 2018 a27. All rights reserved.
//

import UIKit

class ListViewController: UIViewController {
    
    // MARK: - Variabel Decalartions
    
    
    ///////////////////////////////////////////
    
    
    // MARK: - IBOutlets
    
    
    ///////////////////////////////////////////
    
    
    // MARK: - Views
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    ///////////////////////////////////////////
    
    
    // MARK: - IBActions
    
    @IBAction func mapButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "showMap_Segue", sender: self)
    }
    
    ///////////////////////////////////////////
    
}
